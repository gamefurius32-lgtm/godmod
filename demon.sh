#!/bin/bash
set -e

source /venv/main/bin/activate

WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR=${WORKSPACE}/ComfyUI

echo "=== Vast.ai ComfyUI provisioning (WAN 2.2 REAL WORKING TEMPLATE) ==="

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
mkdir -p custom_nodes

if [[ ! -d "custom_nodes/ComfyUI-Manager" ]]; then
    git clone https://github.com/ltdrdata/ComfyUI-Manager custom_nodes/ComfyUI-Manager
else
    (cd custom_nodes/ComfyUI-Manager && git pull)
fi

pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt || true

# ─────────────────────────────────────────────
# 4. Download helper (HF SAFE)
# ─────────────────────────────────────────────
download() {
    local dir="$1"
    local url="$2"
    mkdir -p "$dir"
    echo "→ $url"
    wget -nc --content-disposition "$url" -P "$dir"
}

# ─────────────────────────────────────────────
# 5. MODELS (REAL URLS)
# ─────────────────────────────────────────────

# Diffusion
download "models/diffusion_models" \
"https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_animate_14B_bf16.safetensors"

download "models/diffusion_models" \
"https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors"

# LoRAs
download "models/loras" \
"https://huggingface.co/lightx2v/Wan2.2-I2V-A14B-Moe-Distill-Lightx2v/resolve/main/loras/low_noise_model_rank64.safetensors"

download "models/loras" \
"https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_animate_14B_relight_lora_bf16.safetensors"

# CLIP Vision
download "models/clip_vision" \
"https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"

# Text encoder
download "models/text_encoders" \
"https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# VAE
download "models/vae" \
"https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

# Detection / Pose
download "models/detection" \
"https://huggingface.co/Kijai/vitpose_comfy/resolve/ae68f4e542151cebec0995b8469c70b07b8c3df4/onnx/vitpose_h_wholebody_model.onnx"

download "models/detection" \
"https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx"

# ─────────────────────────────────────────────
# 6. Launch
# ─────────────────────────────────────────────
echo "=== Starting ComfyUI ==="
python main.py --listen 0.0.0.0 --port 8188
