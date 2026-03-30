import re
import matplotlib.pyplot as plt

def plot_loss(log_file_path, output_image_path):
    epochs = []
    losses = []

    # Regex to capture logs like: 2026-03-29 22:04:20 main.py 183: Epoch 42 : Loss 0.0777147
    pattern = re.compile(r'Epoch\s+(\d+)\s+:\s+Loss\s+([\d\.]+)')

    print("Parsing stdout log for loss metrics...")
    try:
        with open(log_file_path, 'r') as f:
            for line in f:
                match = pattern.search(line)
                if match:
                    epoch = int(match.group(1))
                    loss = float(match.group(2))
                    epochs.append(epoch)
                    losses.append(loss)
    except Exception as e:
        print(f"Error reading {log_file_path}: {e}")
        return

    if not epochs:
        print("No loss data found in log. Ensure log format is correct.")
        return

    # Create a nice looking plot
    plt.figure(figsize=(10, 6))
    plt.plot(epochs, losses, marker='o', linestyle='-', color='#1f77b4', linewidth=2, markersize=5, label='Training Loss')
    
    # Customize aesthetics
    plt.title('CoachMe PyTorch Distributed Pretraining (50 Epochs)', fontsize=16, fontweight='bold', pad=20)
    plt.xlabel('Epoch', fontsize=12)
    plt.ylabel('Loss', fontsize=12)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.xticks(epochs[::5] + [epochs[-1]]) # Show every 5th epoch and the last one
    
    # Emphasize the lowest loss
    min_loss = min(losses)
    min_epoch = epochs[losses.index(min_loss)]
    plt.axvline(x=min_epoch, color='red', linestyle=':', alpha=0.5)
    plt.annotate(f'Minimum Loss: {min_loss:.4f}',
                 xy=(min_epoch, min_loss),
                 xytext=(min_epoch, min_loss + 0.5),
                 arrowprops=dict(facecolor='black', shrink=0.05, width=1, headwidth=6),
                 fontsize=10,
                 horizontalalignment='left')

    plt.legend()
    plt.tight_layout()
    
    # Save chart
    plt.savefig(output_image_path, dpi=300)
    print(f"Loss curve successfully generated and saved to {output_image_path}!")

if __name__ == "__main__":
    LOG_FILE = "results/pretrain/stdout.log"
    OUT_IMG = "training_loss_curve.png"
    plot_loss(LOG_FILE, OUT_IMG)
