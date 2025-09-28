import argparse
import json
import torch
from PIL import Image
import numpy as np

def load_labels(path="labels.json"):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return [f"class_{i}" for i in range(1000)]

def preprocess(img: Image.Image) -> torch.Tensor:
    img = img.convert("RGB").resize((224, 224))
    arr = np.asarray(img).astype("float32") / 255.0
    mean = np.array([0.485, 0.456, 0.406], dtype="float32")
    std = np.array([0.229, 0.224, 0.225], dtype="float32")
    arr = (arr - mean) / std
    arr = arr.transpose(2, 0, 1)
    return torch.from_numpy(arr).unsqueeze(0)

def main():
    parser = argparse.ArgumentParser(description="Run inference with TorchScript model")
    parser.add_argument("image_path", help="Path to input image (jpg/png)")
    parser.add_argument("--model", default="model.pt", help="Path to TorchScript model")
    parser.add_argument("--topk", type=int, default=3)
    args = parser.parse_args()

    model = torch.jit.load(args.model, map_location="cpu")
    model.eval()

    labels = load_labels()
    img = Image.open(args.image_path)
    inp = preprocess(img)

    with torch.no_grad():
        logits = model(inp)
        probs = torch.softmax(logits, dim=1)[0]
        topk = torch.topk(probs, k=args.topk)

    print("Top predictions:")
    for score, idx in zip(topk.values.tolist(), topk.indices.tolist()):
        label = labels[idx] if 0 <= idx < len(labels) else f"class_{idx}"
        print(f"{label}: {score:.4f}")

if __name__ == "__main__":
    main()
