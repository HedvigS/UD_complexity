# Get Çöltekin & Rama's complexity metric MFH as calculated on the treebanks in data/ud-treebanks-v2.14.

from pathlib import Path
from rich import print
from tqdm import tqdm
import polars as pl
import numpy as np

from pycode_ud.mlc_morph import get_mfh, read_treebank

def get_all_treebank_names(
        treebanks_dir: Path,
)-> list[str]:
    """
    Get all treebank names from the specified directory.
    
    """

    # List all directories in the treebanks directory
    treebank_names = [
        item.name for item in treebanks_dir.iterdir() if item.is_dir() and item.name.startswith("UD_")
    ]

    # Return the list of treebank names
    return treebank_names

def get_mfh_from_treebank_name(
        treebank_name: str
):
    """
    Load a treebank and calculate its mean feature entropy.
    
    """

    # Build the path to the treebank
    fpath_treebank = Path("data") / "ud-treebanks-v2.14" / treebank_name

    # print(f"[blue]Reading treebank:[/blue] {treebank_name} from {str(fpath_treebank)}")

    # Get the sentences from the treebank
    sentences = read_treebank(str(fpath_treebank))

    # print(f"[blue]Calculating MFH for treebank:[/blue] {treebank_name}")

    # Get the MFH value (and the part-of-speech entropy value)
    mfh_value, pos_entropy_value, dict_extra_info = get_mfh(sentences)

    # Return the MFH value
    return mfh_value, dict_extra_info

def main(treebanks_dir: Path):
    """
    Get MFH values for all treebanks in the specified directory.
    """

    # Get all treebank names
    treebank_names = get_all_treebank_names(treebanks_dir)

    # Initialise dataframe to store results
    results_df = pl.DataFrame({
        "treebank_name": treebank_names,
    })

    # Iterate over each treebank and calculate its MFH value
    it  = results_df.iter_rows(named=True)

    # Initialise list of mfh values
    mfh_values = []

    # Loop over the iterator with a progress bar
    for row in tqdm(it, total=len(treebank_names), desc="Calculating MFH values"):
        treebank_name = row["treebank_name"]

        # Get the MFH value for the current treebank
        mfh_value, dict_extra_info = get_mfh_from_treebank_name(treebank_name)

        # Update the results list
        mfh_values.append(mfh_value)
        
    # Add the MFH values to the results dataframe
    results_df = results_df.with_columns(
        pl.Series("mfh_value", [f"{mfh_value:.4f}" for mfh_value in mfh_values])
    )

    # Return the results dataframe
    return results_df

if __name__ == "__main__":

    # # Example usage
    # treebank_name = "UD_Zaar-Autogramm"
    # mfh_value, dict_extra_info = get_mfh_from_treebank_name(treebank_name)
    # print(f"[green]MFH value for {treebank_name}:[/green] {mfh_value:.4f}")

    # Run main and output to sandbox
    output_dir = Path("sandbox/output")

    # Make sure output directory exists
    output_dir.mkdir(parents=True, exist_ok=True)

    # Get MFH values for all treebanks
    treebanks_dir = Path("data") / "ud-treebanks-v2.14"
    results_df = main(treebanks_dir)

    # Save results to TSV
    output_fpath = output_dir / "ud_treebanks_mfh_values.tsv"
    results_df.write_csv(output_fpath, separator="\t")