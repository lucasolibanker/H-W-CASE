# Sobe o laboratório e deixa o terminal em attacks, com o .venv ativo.
# Uso: ./inicializador.sh
# Primeira vez, ou depois de mudar código: ./inicializador.sh build

_sobe_main() {
  local root build_flag
  root="/mnt/c/Case Entrevista - HeW/Motor-antifraudes"
  build_flag="${1:-}"

  cd "$root" || return 1

  if [[ ! -f .env ]]; then
    cp .env.example .env
    echo "criei .env a partir de .env.example"
  fi

  if [[ ! -d .venv ]]; then
    python3 -m venv .venv || return 1
    # shellcheck disable=SC1091
    source .venv/bin/activate
    python -m pip install -r requirements-dev.txt || return 1
  else
    # shellcheck disable=SC1091
    source .venv/bin/activate
  fi

  if [[ "$build_flag" == "build" ]]; then
    docker compose up -d --build --wait || return 1
  else
    docker compose up -d --wait || return 1
  fi

  cd "$root/attacks" || return 1
  echo "laboratorio no ar"
  echo "dashboard: http://localhost:8000/dashboard"
  echo "pasta atual: $(pwd)"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  _sobe_main "$@"
  _root="/mnt/c/Case Entrevista - HeW/Motor-antifraudes"
  _rc="$(mktemp)"
  cat > "$_rc" <<EOF
[ -f "\$HOME/.bashrc" ] && source "\$HOME/.bashrc"
source "$_root/.venv/bin/activate"
cd "$_root/attacks"
rm -f "$_rc"
EOF
  exec bash --init-file "$_rc" -i
else
  _sobe_main "$@"
  unset -f _sobe_main
fi
