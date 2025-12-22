# Get Çöltekin & Rama's complexity metric MFH as calculated on the treebanks in data/ud-treebanks-v2.14.

from pathlib import Path
from rich import print
from tqdm import tqdm
import polars as pl
import numpy as np
import argparse
import os

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

def get_mfh_from_dataframe(
        df_nodes: pl.DataFrame
):
    """
    Calculate the mean feature entropy from a dataframe of nodes.
    
    """

    # print(f"[blue]Calculating MFH from dataframe...[/blue]")

    # Get the MFH value (and the part-of-speech entropy value)
    mfh_value, pos_entropy_value, dict_extra_info = get_mfh(
        sentences=None,
        df_nodes=df_nodes
    )

    # Return the MFH value
    return mfh_value, dict_extra_info

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

def main(
        bool_test=False,
    ):
    """
    Get MFH values for all treebanks in the specified directory.
    Save to code/output/mfh_stacked.tsv, or code/output_test/mfh_stacked.tsv if in test mode.
    """

    # Inform the user
    if bool_test:
        print(f"[yellow]Calculating mean feature entropy in test mode...[/yellow]")
    else:
        print(f"[blue]Calculating mean feature entropy...[/blue]")

    # Ensure working directory is at the top level (i.e. one level above both pycode_ud/ and code/; directory is UD_complexity/)
    if Path.cwd().name == "pycode_ud" or Path.cwd().name == "code":
        os.chdir(Path.cwd().parent)
    
    # Now fail if we are not at the top level
    if not Path.cwd().name == "UD_complexity": 
        print(f"[red]Current working directory should be UD_complexity/, but is {str(Path.cwd())}[/red]")
        exit(1)

    # Build output directory path, output filepath, and input directory path
    dir_output = Path("code") / ("output_test" if bool_test else "output")
    fpath_output = dir_output / "results" / "mfh_stacked.tsv"
    dir_input = dir_output / "processed_data" / "ud-treebanks-v2.14_collapsed"

    # Get all TSV files in the input directory
    list_tsv_files = sorted(dir_input.glob("*.tsv"))

    # If there are none, print error message and exit.
    if len(list_tsv_files) == 0:
        print(f"[red]No TSV files found in {str(dir_input)}[/red]")
        exit(1)

    # Prepare output dataframe
    df_out = pl.DataFrame({
        "dir": [],
        "mfh": [],
        "n_total_rows": [],
        "n_total_rows_filtered": [],
    })

    # Set schema
    df_out = df_out.with_columns([
        pl.col("dir").cast(pl.Utf8),
        pl.col("mfh").cast(pl.Float64),
        pl.col("n_total_rows").cast(pl.Int64),
        pl.col("n_total_rows_filtered").cast(pl.Int64),
    ])

    # For each TSV file...
    for tsv_fpath in tqdm(list_tsv_files, desc="Processing treebanks"):
        
        # Get the treebank name from the filename
        treebank_name = tsv_fpath.stem

        # Read the TSV file into a Polars DataFrame
        df_nodes = pl.read_csv(tsv_fpath, separator="\t", ignore_errors=True, infer_schema=False) # all should be strings

        # Calculate MFH from the DataFrame
        mfh_value, dict_extra_info = get_mfh_from_dataframe(df_nodes)

        # Append the result to the output dataframe
        df_new = pl.DataFrame({
                "dir": [str(treebank_name)],
                "mfh": [float(mfh_value)],
                "n_total_rows": [dict_extra_info.get("n_total_rows", -1)],
                "n_total_rows_filtered": [dict_extra_info.get("n_total_rows_filtered", -1)],
            })

        # Stack the new dataframe to the output dataframe
        df_out = pl.concat([df_out, df_new], how="vertical")
    
    # Check the output directory exists, create if not
    dir_output_results = fpath_output.parent
    dir_output_results.mkdir(parents=True, exist_ok=True)

    # Append the result to the output file
    df_out.write_csv(fpath_output, separator="\t")

    print(f"[green]MFH calculation complete. Results saved to {str(fpath_output)}[/green]")

if __name__ == "__main__":

    # Argument parser
    parser = argparse.ArgumentParser(description="Calculate MFH for UD treebanks.")

    # Add -t for test mode
    parser.add_argument(
        "-t",
        "--test",
        action="store_true",
        help="Run in test mode with a test dataframe.",
    )

    # Call main
    args = parser.parse_args()
    main(bool_test=args.test)

    