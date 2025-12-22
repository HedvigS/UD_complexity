# Implement the Holm–Bonferroni method for multiple comparisons correction to p-values.
# The idea is that if you do a bunch of statistical tests, you might get some significant p-values,
# but because you did many of them, there's a chance some of them are false positives.
# So you should be somewhat more strict about what gets to count as "significant".
# Holm-Bonferroni takes a list of p-values and adjusts them in light of something called "family-wise error rate" (FWER).
# See e.g. https://en.wikipedia.org/wiki/Holm%E2%80%93Bonferroni_method.

import os
from pathlib import Path
import polars as pl
from rich import print

ALPHA = 0.05
DIR_CORRELATION_DFS = Path("code") / "output" / "results" / "correlation_dfs"
DICT_ADJUSTMENT_GROUPS = {
    "correlation_df_metrics_external_CR.tsv": [
        "Surprisal feat agg_level = UPOS all features_TTR",
        "Feat cat (n) all features_Surprisal feat agg_level = UPOS all features",
        "Çöltekin & Rama's mfh (slightly modified version)_Surprisal feat agg_level = UPOS all features",
        "Surprisal featstring agg_level = lemma core features only_TTR",
        "Feat cat (n) all features_Surprisal featstring agg_level = lemma core features only",
        "Çöltekin & Rama's mfh (slightly modified version)_Surprisal featstring agg_level = lemma core features only",
        "Feat cat (n) all features_TTR",
        "Çöltekin & Rama's mfh (slightly modified version)_TTR",
        "Çöltekin & Rama's mfh (slightly modified version)_Feat cat (n) all features",
    ],
    "correlation_df_metrics_external_CR_PUD.tsv": [
        "Surprisal feat agg_level = UPOS all features_TTR",
        "Feat cat (n) all features_Surprisal feat agg_level = UPOS all features",
        "Çöltekin & Rama's mfh (slightly modified version)_Surprisal feat agg_level = UPOS all features",
        "Surprisal featstring agg_level = lemma core features only_TTR",
        "Feat cat (n) all features_Surprisal featstring agg_level = lemma core features only",
        "Çöltekin & Rama's mfh (slightly modified version)_Surprisal featstring agg_level = lemma core features only",
        "Feat cat (n) all features_TTR",
        "Çöltekin & Rama's mfh (slightly modified version)_TTR",
        "Çöltekin & Rama's mfh (slightly modified version)_Feat cat (n) all features",
    ],
    "correlation_df_metrics_external_Grambank.tsv": [
        "Fusion (Grambank v1.0)_Surprisal feat agg_level = UPOS all features",
        "Informativity (Grambank v1.0)_Surprisal feat agg_level = UPOS all features",
        "Fusion (Grambank v1.0)_Surprisal featstring agg_level = lemma core features only",
        "Informativity (Grambank v1.0)_Surprisal featstring agg_level = lemma core features only",
        "Fusion (Grambank v1.0)_TTR",
        "Informativity (Grambank v1.0)_TTR",
        "Feat cat (n) all features_Fusion (Grambank v1.0)",
        "Feat cat (n) all features_Informativity (Grambank v1.0)",
        "Çöltekin & Rama's mfh (slightly modified version)_Fusion (Grambank v1.0)",
        "Çöltekin & Rama's mfh (slightly modified version)_Informativity (Grambank v1.0)",
    ],    
    "correlation_df_metrics_external_Grambank_PUD.tsv": [
        "Fusion (Grambank v1.0)_Surprisal feat agg_level = UPOS all features",
        "Informativity (Grambank v1.0)_Surprisal feat agg_level = UPOS all features",
        "Fusion (Grambank v1.0)_Surprisal featstring agg_level = lemma core features only",
        "Informativity (Grambank v1.0)_Surprisal featstring agg_level = lemma core features only",
        "Fusion (Grambank v1.0)_TTR",
        "Informativity (Grambank v1.0)_TTR",
        "Feat cat (n) all features_Fusion (Grambank v1.0)",
        "Feat cat (n) all features_Informativity (Grambank v1.0)",
        "Çöltekin & Rama's mfh (slightly modified version)_Fusion (Grambank v1.0)",
        "Çöltekin & Rama's mfh (slightly modified version)_Informativity (Grambank v1.0)",
    ],
}

def holm_bonferroni(
        p_values:list[float], 
        alpha:float=0.05
    )->list[float]:
    """
    Apply the Holm-Bonferroni method to adjust p-values for multiple comparisons.

    Parameters
    ----------
    p_values : list of float
        List of p-values to be adjusted.
    alpha : float, optional
        Significance level, by default 0.05.
    Returns
    -------
    list of float
        Adjusted p-values.
    """

    # 0. Set the length of the list, which will be part of the multiplier for adjusted p-values
    m = len(p_values)

    # 1. Sort the p-values in ascending order, keeping track of their original indices
    sorted_indices = sorted(range(len(p_values)), key=lambda i: p_values[i]) # list of which entries in p_values are smallest to largest
    sorted_p_values = [p_values[i] for i in sorted_indices] # p-values themselves sorted from smallest to largest

    # 2. The new p-values are (m+1-i) * p_(i), where i is the rank (1 for smallest, m for largest).
    # Since we're zero-indexed in Python, this becomes (m - i) * p_(i)
    adjusted_sorted_p_values = [
        min((m - i) * p_val, 1.0) for i, p_val in enumerate(sorted_p_values) # 1 is the highest possible p-value
    ]

    # 3. Ensure that the adjusted p-values are non-decreasing
    for i in range(1, m):
        if adjusted_sorted_p_values[i] < adjusted_sorted_p_values[i - 1]:
            adjusted_sorted_p_values[i] = adjusted_sorted_p_values[i - 1]

    # 4. Reorder adjusted p-values so they match the original order
    adjusted_p_values = [0] * m
    for i, idx in enumerate(sorted_indices):
        adjusted_p_values[idx] = adjusted_sorted_p_values[i]

    return adjusted_p_values

def main():
    """
    Run Holm-Bonferroni on specific groups of results within specific TSV files.
    Add the adjusted p-values as a new column to the TSV files, 
    with "" for rows that don't belong to the specified groups.
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

    # 1. For each fname and list in DICT_ADJUSTMENT_GROUPS...
    for fname, list_adjustment_group in DICT_ADJUSTMENT_GROUPS.items():

        if len(list_adjustment_group) == 0:
            print(f"[yellow]Warning: No adjustment group specified for file '{fname}'. Skipping.[/yellow]")
            continue

        # a. Load the correlation df
        path_correlation_df = DIR_CORRELATION_DFS / fname
        df_correlation = pl.read_csv(path_correlation_df, separator="\t")

        # b. For each row signified by a pair_key in list_adjustment_groups, get the p-value
        p_values_to_adjust = []
        for pair_key in list_adjustment_group:
            row = df_correlation.filter(pl.col("pair_key") == pair_key)

            # Ensure there is exactly one row for this pair_key
            if row.height != 1:
                print(f"[red]Error: Expected exactly one row for pair_key '{pair_key}' in file '{fname}', but found {row.height} rows.[/red]")
                exit(1)
            
            # Get the p-value
            p_value = row.select(pl.col("pvalue")).to_series().item()

            # Add to list of p-values to adjust
            p_values_to_adjust.append(p_value)

        # c. Apply Holm-Bonferroni to the list of p-values
        adjusted_p_values = holm_bonferroni(p_values_to_adjust, alpha=ALPHA)

        # How many of the original p-values were below or equal to ALPHA?
        num_originally_significant = sum(1 for p in p_values_to_adjust if p <= ALPHA)
        print(f"[blue]In file '{fname}', {num_originally_significant} out of {len(p_values_to_adjust)} p-values were originally <= {ALPHA}.[/blue]")

        # Check for any p-values that were previously <= ALPHA but are now > ALPHA
        bool_no_values_became_nonsignificant = True
        for original_p, adjusted_p, pair_key in zip(p_values_to_adjust, adjusted_p_values, list_adjustment_group):
            if original_p <= ALPHA and adjusted_p > ALPHA:
                bool_no_values_became_nonsignificant = False
                print(f"[yellow]Warning: For pair_key '{pair_key}' in file '{fname}', original p-value {original_p:.16f} was <= {ALPHA}, but adjusted p-value {adjusted_p:.16f} is > {ALPHA}.[/yellow]")
        if bool_no_values_became_nonsignificant:
            print(f"[green]All p-values that were originally <= {ALPHA} in file '{fname}' remain <= {ALPHA} after adjustment.[/green]")

        # d. Create a new column in the df for adjusted p-values, defaulting to None
        df_correlation = df_correlation.with_columns(
            pl.lit(None).alias("pvalue_holm_bonferroni")
        )

        # e. For each pair_key in list_adjustment_groups, set the adjusted p-value in the new column
        for pair_key, adjusted_p_value in zip(list_adjustment_group, adjusted_p_values):
            df_correlation = df_correlation.with_columns(
                pl.when(pl.col("pair_key") == pair_key)
                .then(pl.lit(adjusted_p_value))
                .otherwise(pl.col("pvalue_holm_bonferroni"))
                .alias("pvalue_holm_bonferroni")
            )

        # f. Ensure the pvalue and pvalue_holm_bonferroni columns are formatted to 16 decimal places
        df_correlation = df_correlation.with_columns(
            pl.col("pvalue").map_elements(lambda x: f"{x:.16f}" if x is not None else "").alias("pvalue"),
            pl.col("pvalue_holm_bonferroni").map_elements(lambda x: f"{x:.16f}" if x is not None else "").alias("pvalue_holm_bonferroni"),
        )

        # g. Save the updated df back to the TSV file
        df_correlation.write_csv(path_correlation_df, separator="\t")
        print(f"[green]Updated file '{fname}' with Holm-Bonferroni adjusted p-values.[/green]")

if __name__ == "__main__":

    main()

    # # Example (from Wikipedia)
    # p_values = [0.01, 0.04, 0.03, 0.005]
    # alpha = 0.05

    # adjusted_p_values = holm_bonferroni(p_values, alpha)
    # print("Original p-values: ", p_values)
    # print("Adjusted p-values: ", adjusted_p_values)