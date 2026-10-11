# system
My fedora config

What I want next:
1. Niri
2. Waybar
3. My wallpapers
4. Kitty terminal
5. Neovim for cpp and python
6. rofi
7. Beautiful lockscreen
8. My keybinds
9. Blured terminal theme and other programs
10. My config from monkeytype
11. My aliases

# Ионосфера по IRI

Каталог содержит C++ порт модели IRI-2020 в части **электронной плотности**
$N_e(h)$, [м<sup>−3</sup>]. Вход: геодезические координаты, время, индексы солнечной
активности. Выход: $N_e$ в каждой заданной точке.

---

Ионосфера делится на слои, в каждом их которых расчет электронной плотности отличается. Формулы для электронной плотности используют разные вспомогательные параметры (`f0F2`, `hmF2`, `B0`, `hVT`, ...), не зависящие от слоя. Вспомонательные параметры вычисляются при первом вызове.

---

## Профиль $N_e(h)$ сверху вниз

`iri_details::ne_at` в [`ne_calc.hpp`](iri/ne_calc.hpp) сравнивает высоту `h`
[км] с заранее посчитанными границами и вызывает одну из шести моделей.

### 1. Topside: `h >= hmF2` (`NeQuick`)

Из четырёх вариантов в Fortran `XE1` перенесён только NeQuick.

```math
\Delta h = h - \mathrm{hmF2},\qquad
z = \frac{\Delta h}{\mathrm{B2top}\left(1 + \dfrac{r\,g\,\Delta h}{r\,\mathrm{B2top} + g\,\Delta h}\right)},
\qquad g = 0.125,\ r = 100
```

```math
N_e = \mathrm{NmF2}\,\frac{4e^{z}}{(1+e^{z})^{2}}
```

### 2. F2: `hmF1 <= h < hmF2` (`NeF2Model`)

Толщина `B0` [км], форма `B1`.

```math
x = \max\left(0,\ \frac{\mathrm{hmF2} - h}{\mathrm{B0}}\right),\qquad
N_e = \mathrm{NmF2}\,\frac{e^{-x^{\mathrm{B1}}}}{\cosh x}
```

### 3. F1: `HZ <= h < hmF1` (`NeF1Model`)
**Слой F1 может отсутствовать**

Отдельной формулы пика нет: в формулу п. 2 подставляется преобразованная высота.

```math
h^{\ast\ast} = \mathrm{hmF1}\left(1 - \left(\frac{\mathrm{hmF1}-h}{\mathrm{hmF1}}\right)^{1+\mathrm{C1}}\right),\qquad
N_e(h) = N_e^{\mathrm{F2}}(h^{\ast\ast})
```

Если F1 нет: $h^{\ast\ast} = h$, то есть та же формула, что в п. 2, на всём
`[HZ, hmF2)`.

### 4. Промежуточная область: `hVT <= h < HZ` (`NeInterModel`)

Отдельной формулы пика нет: в формулу п. 3 подставляется преобразованная высота.

Прямое продолжение F1 вниз пересекает `NmE` на высоте `hST`, обычно ниже `hVT` .

`hST` - корень $N_e^{\mathrm{F1}}(h)=\mathrm{NmE}$, либо его нет(`nullopt`). `HZ = (h_low + ctx.hST_bracket_low())/2`, где `h_low = hST`, если корень найден, иначе `hVT`

В коде три ветки (`h_ref` = `hVT`):

1. **`hST` нет.** Линейная интерполяция между `NmE` на `hVT` и $N_e^{\mathrm{F1}}(\mathrm{HZ})$ на `HZ`.

2. **`hST == hVT`.** Отображение не нужно:

```math
N_e(h) = N_e^{\mathrm{F1}}(h)
```

3. **`hST` есть и `hST != hVT`.**

```math
s = \frac{(\mathrm{HZ}-\mathrm{hST})^{2}}{\mathrm{hST}-\mathrm{hVT}},\qquad
h_1 = \mathrm{HZ} + \frac{s}{2} \mp \sqrt{s\left(\frac{s}{4}-(h-\mathrm{HZ})\right)}
```

минус при `hST > hVT`, плюс иначе.

```math
N_e(h) = N_e^{\mathrm{F1}}(h_1)
```

$N_e^{\mathrm{F1}}$ - формула п. 3 (с преобразованием F1, если слой есть).

### 5. Долина E: `hmE <= h < hVT` (`NeEModel`)
**Долина E может отсутствовать**

```math
x = h - \mathrm{hmE},\qquad
P(x) = c_0 x^{2} + c_1 x^{3} + c_2 x^{4} + c_3 x^{5}
```

```math
N_e = \begin{cases}
\mathrm{NmE}\,(1+P(x)), & \text{день},\\
\mathrm{NmE}\,e^{P(x)}, & \text{ночь}.
\end{cases}
```

### 6. Низ E и D: `ne_lower_boundary <= h < hmE` (`NeDModel`)

Граница между E и D - `hDX`.

**D, `h <= hDX`.** $z = h - \mathrm{hmD}$:

```math
N_e = \mathrm{NmD}\,\exp\bigl(z\,(F_{P1} + z\,(F_{P2} + z\,F_{P3}))\bigr)
```

**Низ E, `hDX < h < hmE`.** $u = \mathrm{hmE}-h$:

```math
N_e = \mathrm{NmE}\,\exp(-D_1 u^{p})
```

---

## Точка входа

[`iri/ne_calc.hpp`](iri/ne_calc.hpp):

```cpp
#include "otk/models/ionosphere/iri/ne_calc.hpp"

using namespace otk::models;

std::vector<Geodetic>      coords = {/* lat, lon: рад; h: м; size = n */};
std::vector<time::Calendar> times = {/* size = 1 or size = n */};
std::vector<SolarActivity>  solar = {/* size = 1 or size = n */};

std::vector<otk::scalar> ne = Ne(coords, times, solar);   // ne[i]: м^-3
```

---

## Параметры слоёв

Все параметры лежат в `IriContext` и считаются при первом обращении. Каждый
параметр считает статический метод `compute(ctx)` модели из `IriParamPolicy`.
Тип модели по умолчанию задан в [`default_iri_policy.hpp`](iri/default_iri_policy.hpp).

| Параметр | Смысл | Единицы | Модель по умолчанию |
|----------|-------|---------|---------------------|
| `f0F2` | критическая частота F2 | МГц | `F0F2URSIModel` |
| `M3000F2` | $M(3000)F2$, коэффициент | 1 | `MUFIri22Model` |
| `hmF2` | высота пика F2 | км | `HmF2Shu2015Model` |
| `B0`, `B1` | толщина и форма F2 снизу | км, 1 | `B0B1ABT2009Model` |
| `F1_exists` | есть ли слой F1 | bool | `ExistenceF1ProbabilityModel` + `HmF1Iri22Model` |
| `f0F1` | критическая частота F1 | МГц | `F0F1DuCharmeModel` |
| `hmF1` | высота пика F1 | км | `HmF1Iri22Model` |
| `C1` | форма F1 | 1 | `C1F1ReinischModel` |
| `f0E` | критическая частота E | МГц | `F0ECCIRModel` |
| `hmE` | высота пика E | км | `HmEConstantModel` (110) |
| `hVB` | дно долины E | км | `HVBIri22Model` |
| `hVT` | верх долины E | км | `HVTIri22Model` |
| `hST` | высота, где профиль F1/F2 даёт $N_e = N_mE$ | км | `HSTIri22Model` |
| `HZ` | нижняя граница F1, верх промежуточной области | км | `HZIri22Model` |
| `hmD` | опорная высота D, где $N_e = \mathrm{NmD}$ | км | `HmDIri22Model` |
| `nmD` | концентрация на `hmD` | м<sup>−3</sup> | `NmDBilitza78Model` |
| `hDX` | сшивка D с нижней частью E | км | `HDXIri22Model` |

Скалярные величины, которые не относятся к слоям, `IriContext` берёт из
`ctx.config()`.

Магнитное поле считается через GeographicLib и коэффициенты IGRF-14 (`utility/igrf_data/igrf14.wmm`), оригинальная IRI использует `igrf.for`. Формулы наклонения, `DIPL` и `MODIP` взяты из IRI.

---

## День и ночь

Многие параметры (`hmD`, `hDX`, параметры долины E, `C1`) имеют разные дневные
и ночные значения и переключаются плавно. Для этого используется `HPOL`
([`utility/functions.hpp`](iri/utility/functions.hpp)).

Восход и закат берутся на константных заданных высотах соответствующей области:

| Область | Высота | Где задана |
|---------|--------|------------|
| D | 80 км | `iri_details::d_region_height` |
| E | 110 км | `iri_details::e_region_height` |
| C1 (F1) | 200 км | `C1F1ReinischModel` |

Времена восхода и захода: `IriConfig::SR(height_km)`, `IriConfig::SS(height_km)`,
местное время: `IriConfig::lt_hours()`. Значения $\pm 99$ кодируют полярный день
и полярную ночь.

---

## Индексы солнечной активности

Нужно передать `SolarActivity` ([`utility/sun_params.hpp`](iri/utility/sun_params.hpp)):

| Поле | Смысл | По умолчанию | Где используется |
|------|-------|--------------|------------------|
| `F107_81` | $F_{10.7}$, среднее за 81 день, sfu | 70 | `hmF2` (Shu2015); источник $R_{12}$, если `R12` не задан |
| `F107_365` | $F_{10.7}$, среднее за год, sfu | 70 | `f0E` |
| `F107_d` | $F_{10.7}$ за сутки, sfu | 70 | не используется текущими моделями |
| `R12` | число пятен, 12-месячное среднее | `nullopt` | `M3000F2`, `B0B1`, `nmD`, `f0F1`, F1, $B2_{\mathrm{top}}$ |
| `IG12` | ионосферный индекс | `nullopt` | `f0F2` |

Если `R12` не задан, он обращается из $F_{10.7,81}$:

```math
F_{10.7} = 63.75 + R_{12}\,(0.728 + 0.00089\,R_{12})
```

Если `IG12` не задан, считается из $R_{12}$:

```math
IG_{12} = (-0.0031\,R_{12} + 1.5332)\,R_{12} - 11.5634
```

**В Fortran IRI индексы берутся из файлов `ig_rz.dat`: месячные $IG_{12}$ и $R_{12}$ с 01.1958 по 11.2028.**

---

## Замена моделей

Параметры и профили выбираются двумя политиками, обе передаются в `Ne` как
шаблонные аргументы:

```cpp
Ne<IriModelPolicy, IriParamPolicy>(coords, times, solar);
```

| Политика | Что задаёт | По умолчанию |
|----------|------------|--------------|
| `IriParamPolicy` | модель каждого параметра слоя из таблицы выше | `DefaultIriParamPolicy` |
| `IriModelPolicy` | модель $N_e(h)$ для `TopsideModel`, `F2Model`, `F1Model`, `IntermediateModel`, `EModel`, `DModel` | `DefaultIriModelPolicy` |

Модель - структура со статическим методом `compute(ctx)` (для профилей
`compute(ctx, h)`). Чтобы заменить одну модель:

```cpp
struct MyParams : DefaultIriParamPolicy {
    using f0F2Model = F0F2CCIRModel;   // foF2 по картам CCIR вместо URSI
};
auto ne = Ne<DefaultIriModelPolicy, MyParams>(coords, times, solar);
```

Реализованные альтернативные модели: `F0F2CCIRModel`,`ExistenceF1SolarZenithAngleModel`, `ExistenceF1EasyProbabilityModel`

---

## Данные

Таблицы коэффициентов лежат рядом с моделями:

| Данные | Каталог |
|--------|---------|
| карты CCIR (`ccir11.asc` ... `ccir22.asc`), `f0F2`, `M3000F2` | `param_models/realizations/f0F2/f0F2ccir_data/` |
| карты URSI | `param_models/realizations/f0F2/f0F2ursi_data/` |
| коэффициенты hmF2 (`mcsat11.dat` ... `mcsat22.dat`) | `param_models/realizations/hmF2/hmF2_data/` |
| IGRF-14 | `utility/igrf_data/` |
