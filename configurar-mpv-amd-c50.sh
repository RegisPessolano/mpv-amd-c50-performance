#!/usr/bin/env bash
set -Eeuo pipefail

# Configurador de MPV para AMD C-50 / Radeon HD 6250 em sessão X11/XLibre.
# Não precisa ser executado como root. Altera apenas ~/.config/mpv.

MPV_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mpv"
MPV_CONF="$MPV_DIR/mpv.conf"
STAMP="$(date +%Y%m%d-%H%M%S)"

die() { printf 'Erro: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

have mpv || die "mpv não foi encontrado no PATH."

printf 'Configurando MPV para AMD C-50 (X11/XLibre)...\n'
printf 'Versão detectada: %s\n' "$(mpv --version | head -n 1)"

mkdir -p "$MPV_DIR"
if [[ -e "$MPV_CONF" ]]; then
    cp -a -- "$MPV_CONF" "$MPV_CONF.backup-$STAMP"
    printf 'Backup criado: %s\n' "$MPV_CONF.backup-$STAMP"
fi

cat >"$MPV_CONF" <<'EOF'
# MPV: perfil de máximo desempenho para AMD C-50 / Radeon HD 6250
# Sessão gráfica: X11/XLibre. Gerado automaticamente.

# Caminho simples e compatível com a GPU Radeon antiga.
vo=gpu
gpu-api=opengl
gpu-context=x11

# Tenta VA-API direto (menos cópias); depois VA-API com cópia; por último CPU.
# O MPV ignora automaticamente codecs que a GPU não sabe decodificar.
hwdec=vaapi,vaapi-copy

# Evita filtros e sincronização caros. Prioriza reprodução contínua.
scale=bilinear
cscale=bilinear
dscale=bilinear
correct-downscaling=no
linear-downscaling=no
sigmoid-upscaling=no
deband=no
interpolation=no
video-sync=audio
framedrop=vo

# Áudio leve e estável.
audio-channels=stereo
audio-pitch-correction=no

# Há 16 GiB de RAM disponíveis: mantenha um cache generoso em memória.
# Isso ajuda mídias em rede e arquivos com leitura irregular sem gravar cache no SSD.
cache=yes
cache-on-disk=no
demuxer-readahead-secs=120
demuxer-max-bytes=512MiB
demuxer-max-back-bytes=128MiB

# Mensagens na tela úteis sem custo relevante durante a reprodução.
osd-duration=1500

[baixo-consumo]
profile-desc=Máximo desempenho para AMD C-50
scale=bilinear
cscale=bilinear
dscale=bilinear
correct-downscaling=no
linear-downscaling=no
sigmoid-upscaling=no
deband=no
interpolation=no
video-sync=audio
framedrop=vo

[software]
profile-desc=Fallback quando VA-API apresentar tela preta ou artefatos
hwdec=no
vo=xv,gpu
vd-lavc-threads=2
vd-lavc-skiploopfilter=nonref
scale=bilinear
cscale=bilinear
dscale=bilinear
deband=no
interpolation=no
video-sync=audio
framedrop=decoder

[qualidade]
profile-desc=Qualidade um pouco melhor para vídeos leves
hwdec=vaapi,vaapi-copy
scale=spline36
cscale=bilinear
dscale=mitchell
correct-downscaling=yes
deband=no
interpolation=no
video-sync=audio
framedrop=vo
EOF

printf '\nConfiguração gravada em: %s\n' "$MPV_CONF"

printf '\nDiagnóstico da aceleração de vídeo:\n'
if have vainfo; then
    if vainfo 2>&1 | grep -Eq 'VAProfile(H264|MPEG2|VC1|JPEGBaseline)'; then
        printf '  [OK] VA-API está disponível e anunciou ao menos um codec útil.\n'
    else
        printf '  [AVISO] vainfo não anunciou codecs esperados ou retornou erro.\n'
        printf '          No LMDE, tente: sudo apt install vainfo mesa-va-drivers mesa-vdpau-drivers\n'
    fi
else
    printf '  [AVISO] vainfo não está instalado. Para testar: sudo apt install vainfo\n'
fi

printf '\nTeste recomendado:\n'
printf '  mpv --log-file=/tmp/mpv-c50.log SEU_VIDEO.mp4\n'
printf '  Durante o vídeo, pressione i e procure por hwdec/vaapi.\n'
printf '\nSe houver tela preta ou artefatos:\n'
printf '  mpv --profile=software SEU_VIDEO.mp4\n'
printf '\nPara vídeos leves, com imagem um pouco melhor:\n'
printf '  mpv --profile=qualidade SEU_VIDEO.mp4\n'
printf '\nPara desfazer, restaure o arquivo backup mostrado acima.\n'
