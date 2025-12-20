import os
from pathlib import Path
from rich import print
import polars as pl
import matplotlib.pyplot as plt

def plot_results_box_plots(
        df_plot: pl.DataFrame,
        fpath_output: Path,
        measures: list[str],
        labels_measures: dict[str, str],
):
    """
    Create box plots for various measures from the results dataframe.
    """

    # Create box plots
    plt.figure(figsize=(15, 8))
    
    # Prepare data for box plots using polars
    box_data = [df_plot[measure].to_list() for measure in measures]
    
    # Create box plot
    plt.boxplot(box_data, tick_labels=[labels_measures[measure] for measure in measures])
    plt.xticks(rotation=45, ha='right')
    # plt.title("Box Plots of Morphological Complexity Measures and MFH") # No title for manuscript figure
    plt.ylabel("Value (bits)")
    plt.tight_layout()

    # Remove grid
    plt.grid(False)

    # Save the plot
    plt.savefig(str(fpath_output))

    print(f"[green]Box plots saved to:[/green] {str(fpath_output)}")

def main():
    """
    Use all_results.tsv to create box plots for the various measures.
    """

    # Ensure working directory is at the top level (i.e. one level above both pycode_ud/ and code/; directory is UD_complexity/)
    if Path.cwd().name == "pycode_ud" or Path.cwd().name == "code":
        os.chdir(Path.cwd().parent)

    # Get the current working directory
    current_working_directory = Path.cwd()
    
    # Now fail if we are not at the top level
    if not current_working_directory.name == "UD_complexity": 
        print(f"[red]Current working directory should be UD_complexity/, but is {str(current_working_directory)}[/red]")
        exit(1)

    # Load the results
    fpath = current_working_directory / "code" / "output" / "results" / "all_results.tsv"

    # Check the file exists
    if not fpath.exists():
        print(f"[red]File not found:[/red] {str(fpath)}")
        exit(1)

    # Load the data
    df_results = pl.read_csv(str(fpath), separator="\t")

    # Set the measures to plot (and filter by)
    measures = [
        "sum_surprisal_morph_split_mean_lemma_all_features",
        "sum_surprisal_morph_split_mean_lemma_core_features_only",
        "sum_surprisal_morph_split_mean_upos_all_features",
        "sum_surprisal_morph_split_mean_upos_core_features_only",
        "surprisal_per_morph_featstring_mean_lemma_all_features",
        "surprisal_per_morph_featstring_mean_lemma_core_features_only",
        "surprisal_per_morph_featstring_mean_upos_all_features",
        "surprisal_per_morph_featstring_mean_upos_core_features_only",
        "mfh",
    ]

    # Set the readable labels for the measures
    labels_measures = {
        "sum_surprisal_morph_split_mean_lemma_all_features": "Feat / Lemma / All",
        "sum_surprisal_morph_split_mean_lemma_core_features_only": "Feat / Lemma / Core",
        "sum_surprisal_morph_split_mean_upos_all_features": "Feat / UPOS / All",
        "sum_surprisal_morph_split_mean_upos_core_features_only": "Feat / UPOS / Core",
        "surprisal_per_morph_featstring_mean_lemma_all_features": "Featstring / Lemma / All",
        "surprisal_per_morph_featstring_mean_lemma_core_features_only": "Featstring / Lemma / Core",
        "surprisal_per_morph_featstring_mean_upos_all_features": "Featstring / UPOS / All",
        "surprisal_per_morph_featstring_mean_upos_core_features_only": "Featstring / UPOS / Core",
        "mfh": "Mean Feature Entropy (MFH)",
    }

    # Remove ALL rows with 0 for ANY of the measures
    filter_condition = pl.col(measures[0]) > 0
    for measure in measures[1:]:
        filter_condition &= pl.col(measure) > 0

    # Remove rows where n_types <= 2
    filter_condition &= pl.col("n_types") > 2

    # Do the filter
    df_plot = df_results.filter(filter_condition)

    # Call the plotting function
    fpath_output = current_working_directory / "code" / "output" / "plots" / "box_plots_metrics.png"

    # If the directory does not exist, create it
    if not fpath_output.parent.exists():
        fpath_output.parent.mkdir(parents=True, exist_ok=True)

    plot_results_box_plots(
        df_plot=df_plot,
        fpath_output=fpath_output,
        measures=measures,
        labels_measures=labels_measures,
    )

if __name__ == "__main__":
    main()