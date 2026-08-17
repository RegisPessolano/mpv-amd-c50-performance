# MPV para AMD C-50 / Radeon HD 6250

Configuração de alto desempenho do MPV para notebooks antigos com processador
AMD C-50, vídeo integrado Radeon HD 6250 e sessão X11/XLibre.

O instalador prioriza decodificação VA-API, usa filtros leves e oferece fallback
por software. A configuração considera uma máquina com SSD e 16 GiB de RAM,
mantendo um cache generoso exclusivamente na memória.

## Instalação

O MPV deve estar instalado. Depois, execute:

```bash
chmod +x configurar-mpv-amd-c50.sh
./configurar-mpv-amd-c50.sh
```

O arquivo existente em `~/.config/mpv/mpv.conf` recebe um backup com data e
hora antes de ser substituído.

## Uso

Reprodução normal:

```bash
mpv video.mp4
```

Se VA-API produzir tela preta ou artefatos:

```bash
mpv --profile=software video.mp4
```

Para vídeos leves com escalonamento um pouco melhor:

```bash
mpv --profile=qualidade video.mp4
```

## Observação sobre codecs

A Radeon HD 6250 possui UVD3 e é mais adequada a H.264, MPEG-2 e VC-1. HEVC,
VP9 e AV1 normalmente dependem do limitado processador AMD C-50. H.264 em 720p
ou 1080p com bitrate moderado tende a oferecer os melhores resultados.

## Licença

[MIT](LICENSE)
