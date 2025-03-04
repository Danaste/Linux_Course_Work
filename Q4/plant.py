import argparse
import matplotlib.pyplot as plt

def plot_data(plant_name, height, leaf_count, dry_weight):
    print(f"Plant: {plant_name}")
    print(f"Height data: {height} cm")
    print(f"Leaf count data: {leaf_count}")
    print(f"Dry weight data: {dry_weight} g")

    plt.figure(figsize=(10, 6))

    plt.subplot(1, 3, 1)
    plt.scatter(height, leaf_count, c=dry_weight, cmap='viridis')
    plt.title(f"{plant_name} - Scatter Plot")
    plt.xlabel("Height (cm)")
    plt.ylabel("Leaf Count")

    plt.subplot(1, 3, 2)
    plt.hist(dry_weight, bins=5, color='skyblue', edgecolor='black')
    plt.title(f"{plant_name} - Histogram")
    plt.xlabel("Dry Weight (g)")

    plt.subplot(1, 3, 3)
    plt.plot(height, dry_weight, marker='o', color='green')
    plt.title(f"{plant_name} - Line Plot")
    plt.xlabel("Height (cm)")
    plt.ylabel("Dry Weight (g)")

    plt.tight_layout()
    plt.savefig(f"{plant_name}_scatter.png")
    plt.savefig(f"{plant_name}_histogram.png")
    plt.savefig(f"{plant_name}_line_plot.png")
    plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plant data plotting tool")
    parser.add_argument("--plant", type=str, required=True, help="Name of the plant")
    parser.add_argument("--height", type=int, nargs='+', required=True, help="Height data")
    parser.add_argument("--leaf_count", type=int, nargs='+', required=True, help="Leaf count data")
    parser.add_argument("--dry_weight", type=float, nargs='+', required=True, help="Dry weight data")

    args = parser.parse_args()

    plot_data(args.plant, args.height, args.leaf_count, args.dry_weight)

