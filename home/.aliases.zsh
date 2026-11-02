### --- 🐍 Python и Jupyter --- ###

alias py='python3'                     # Запустить Python
alias jl='jupyter lab'                # Jupyter Lab
alias venv='python3 -m venv .venv'    # Создать виртуальное окружение в текущей директории
alias act='source .venv/bin/activate' # Активировать venv
alias deact='deactivate'              # Деактивировать venv

### --- ⚙️ Компиляция C++ с clang++ --- ###

alias cpp='clang++ -std=c++20 -Wall -Wextra'  # Скомпилировать C++ файл → a.out

### --- 🧱 Сборка проектов с Make и CMake --- ###

alias mk='make -j$(nproc)'                        # Сборка make с максимальным числом потоков

alias cm='cmake -S . -B build'                    # Сгенерировать cmake-проект в ./build
alias cmb='cmake --build build -j$(nproc)'        # Скомпилировать cmake-проект

### --- 🧬 Git --- ###

alias gs='git status'                 # Показать статус репозитория
alias ga='git add'                    # Добавить файл в индекс
alias gc='git commit -m'             # Сделать коммит с сообщением
alias gp='git push'                  # Отправить изменения на сервер
alias gl='git pull'                  # Забрать изменения с сервера
alias gb='git branch'                # Показать все ветки
alias gco='git checkout'             # Переключиться на ветку
alias gcm='git checkout main'        # Быстрый переход на ветку main
alias gd='git diff'                  # Показать изменения в коде
alias gcl='git clone'                # Клонировать репозиторий

### --- 🧼 Общие утилиты --- ###

alias la='ls -A'                     # Показать скрытые файлы
alias l='ls -CF'                     # Краткий список файлов
alias ..='cd ..'                     # Перейти в родительскую директорию
alias ...='cd ../..'                 # Перейти на два уровня вверх
alias ....='cd ../../..'            # Перейти на три уровня вверх
alias grep='grep --color=auto'      # Подсвечивать совпадения в grep
alias df='df -h'                     # Использование дисков
alias du='du -h'                     # Размеры папок и файлов
alias free='free -h'                 # Использование оперативной памяти
alias cls='clear'                   # Очистить экран
alias please='sudo'                 # Просто вежливый sudo
alias update='sudo dnf upgrade --refresh' # Обновить систему (Fedora)
alias aliases='nvim ~/.aliases.zsh' # Быстро открыть этот файл

alias swapkill='find ~/.local/state/nvim/swap -type f -name "*.sw?" -exec trash {} +'
alias fortune='fortune | cowsay'
alias vpn='(cd ~/mmcp_internal && sudo openvpn --config mmcp_internal.ovpn)'
alias weather='curl wttr.in/Dolgoprudny'
alias clock='tty-clock tty -c -s -r -C'
alias cmatrix='cmatrix -C'
alias music='cava'
alias obsidian='./Apps/Obsidian-1.11.5.AppImage'
alias timer='termdown'
alias actopenfoam='source /usr/lib/openfoam/openfoam2512/etc/bashrc'
