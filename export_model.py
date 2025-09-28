import json
import torch
from torchvision.models import mobilenet_v2, MobileNet_V2_Weights

def main():
    weights = MobileNet_V2_Weights.DEFAULT
    model = mobilenet_v2(weights=weights)
    model.eval()
    example = torch.randn(1, 3, 224, 224)
    scripted = torch.jit.trace(model, example)
    scripted.save("model.pt")
    categories = weights.meta.get("categories")
    if categories:
        with open("labels.json", "w", encoding="utf-8") as f:
            json.dump(categories, f, ensure_ascii=False, indent=2)
    print("Exported TorchScript model to model.pt and labels.json")

if __name__ == "__main__":
    main()
