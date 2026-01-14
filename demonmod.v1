#!/bin/bash
set -e

source /venv/main/bin/activate

WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR=${WORKSPACE}/ComfyUI

echo "=== Vast.ai ComfyUI provisioning (WAN 2.2 clean template) ==="

# ─────────────────────────────────────────────
# 1. Clone ComfyUI
# ─────────────────────────────────────────────
if [[ ! -d "${COMFYUI_DIR}" ]]; then
    git clone https://github.com/comfyanonymous/ComfyUI.git "${COMFYUI_DIR}"
fi

cd "${COMFYUI_DIR}"

# ─────────────────────────────────────────────
# 2. Install requirements
# ─────────────────────────────────────────────
pip install --no-cache-dir -r requirements.txt

# ─────────────────────────────────────────────
# 3. Custom nodes
# ─────────────────────────────────────────────
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
)

mkdir -p custom_nodes

for repo in "${NODES[@]}"; do
    dir="${repo##*/}"
    path="custom_nodes/${dir}"

    if [[ -d "$path" ]]; then
        (cd "$path" && git pull)
    else
        git clone "$repo" "$path" --recursive
    fi

    [[ -f "$path/requirements.txt" ]] && pip install --no-cache-dir -r "$path/requirements.txt"
done

# ─────────────────────────────────────────────
# 4. MODELS
# ─────────────────────────────────────────────
DIFFUSION_MODELS=(
    "wan2.2_animate_14B_bf16.safetensors"
    "wan2.2_t2v_low_noise_14B_fp16.safetensors"
)

LORA_MODELS=(
    "wan2.2_animate_14B_relight_lora_bf16.safetensors"
    "i2v_lightx2v_low_noise_model.safetensors"
)

CLIP_VISION_MODELS=(
    "clip_vision_h.safetensors"
)

TEXT_ENCODER_MODELS=(
    "umt5_xxl_fp8_e4m3fn_scaled.safetensors"
)

VAE_MODELS=(
    "wan_2.1_vae.safetensors"
)

DETECTION_MODELS=(
    "vitpose_h_wholebody_model.onnx"
    "yolov10m.onnx"
)

# ─────────────────────────────────────────────
# 5. Download helper
# ─────────────────────────────────────────────
download() {
    local dir="$1"
    shift
    mkdir -p "$dir"

    for file in "$@"; do
        echo "Downloading $file → $dir"
        wget -nc --content-disposition -P "$dir" "$file"
    done
}

# ─────────────────────────────────────────────
# 6. Download models (correct paths)
# ─────────────────────────────────────────────
download "models/diffusion_models" "${DIFFUSION_MODELS[@]}"
download "models/loras" "${LORA_MODELS[@]}"
download "models/clip_vision" "${CLIP_VISION_MODELS[@]}"
download "models/text_encoders" "${TEXT_ENCODER_MODELS[@]}"
download "models/vae" "${VAE_MODELS[@]}"
download "models/detection" "${DETECTION_MODELS[@]}"

# ─────────────────────────────────────────────
# 7. Launch
# ─────────────────────────────────────────────
echo "=== Starting ComfyUI ==="
python main.py --listen 0.0.0.0 --port 8188
