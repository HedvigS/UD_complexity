import polars as pl
from pathlib import Path
from rich import print

from pycode_ud.mlc_morph import get_mfh

def test_get_mfh():
    """
    Test mlc_morph.get_mfh by passing in a dataframe and checking it omits the rows it should.

    Test dataframe columns are:
    id	doc_id	paragraph_id	sentence_id	sentence	token_id	token	lemma	upos	xpos	feats	head_token_id	dep_rel	deps	misc
    """

    # Test 1. Create a dataframe with a number and a character.
    # They will have different features, so if the number were NOT excluded,
    # the entropy would be greater than 0.
    # We therefore expect the entropy to be 0, since the number should be excluded.
    df_nodes = pl.DataFrame({
        "id": [1, 2],
        "doc_id": [1, 1],
        "paragraph_id": [1, 1],
        "sentence_id": [1, 1],
        "sentence": ["This is a test.", "This is a test."],
        "token_id": [1, 2],
        "token": ["123", "abc"],
        "lemma": ["123", "abc"],
        "upos": ["NUM", "NOUN"],
        "xpos": ["N", "N"],
        "feats": ["Gender=Male", "Gender=Vegetable"],
        "head_token_id": [0, 1],
        "dep_rel": ["TEST", "TEST"],
        "deps": ["", ""],
        "misc": ["test misc A", "test misc B"],
    })

    # Get the MFH value
    mfh, ph, dict_extra_info = get_mfh(
        sentences=None,
        df_nodes=df_nodes,
    )

    # Check that the MFH is 0, since the number should be excluded
    assert mfh == 0.0, f"Expected MFH to be 0.0, but got {mfh}"

    # Test 2. Add a third row that is a number but alphabetic.
    # This should NOT be excluded, so the MFH should be exactly 1.
    df_nodes = df_nodes.vstack(
        pl.DataFrame({
            "id": [3],
            "doc_id": [1],
            "paragraph_id": [1],
            "sentence_id": [1],
            "sentence": ["This is a test."],
            "token_id": [3],
            "token": ["one"],
            "lemma": ["one"],
            "upos": ["NUM"],
            "xpos": ["N"],
            "feats": ["Gender=Female"],
            "head_token_id": [1],
            "dep_rel": ["TEST"],
            "deps": [""],
            "misc": ["test misc C"],
        })
    )

    # Get the MFH value
    mfh, ph, dict_extra_info = get_mfh(
        sentences=None,
        df_nodes=df_nodes,
    )

    # Check that the MFH is 1.0, since now we have two different features at 50% each.
    assert mfh == 1.0, f"Expected MFH to be 1.0, but got {mfh}"

    # Test 3. Add a fourth row with an empty token. Should still be 1.0.
    df_nodes = df_nodes.vstack(
        pl.DataFrame({
            "id": [4],
            "doc_id": [1],
            "paragraph_id": [1],
            "sentence_id": [1],
            "sentence": ["This is a test."],
            "token_id": [4],
            "token": [""],
            "lemma": ["au"],
            "upos": ["VERB"],
            "xpos": ["."],
            "feats": ["Gender=Empty"],
            "head_token_id": [1],
            "dep_rel": ["TEST"],
            "deps": [""],
            "misc": ["test misc D"],
        })
    )

    # Get the MFH value
    mfh, ph, dict_extra_info = get_mfh(
        sentences=None,
        df_nodes=df_nodes,
    )

    # Check that the MFH is still 1.0, since the empty token should be excluded
    assert mfh == 1.0, f"Expected MFH to be 1.0, but got {mfh}"

    # Test 4. Add a fifth row with an empty lemma. Should still be 1.0.
    df_nodes = df_nodes.vstack(
        pl.DataFrame({
            "id": [5],
            "doc_id": [1],
            "paragraph_id": [1],
            "sentence_id": [1],
            "sentence": ["This is a test."],
            "token_id": [5],
            "token": ["tu"],
            "lemma": [""],
            "upos": ["VERB"],
            "xpos": ["."],
            "feats": ["Gender=Empty"],
            "head_token_id": [1],
            "dep_rel": ["TEST"],
            "deps": [""],
            "misc": ["test misc E"],
        })
    )

    # Get the MFH value
    mfh, ph, dict_extra_info = get_mfh(
        sentences=None,
        df_nodes=df_nodes,
    )

    # Check that the MFH is still 1.0, since the empty lemma should be excluded
    assert mfh == 1.0, f"Expected MFH to be 1.0, but got {mfh}"

    # Test 5. Add a sixth row with a None token. Should still be 1.0.
    df_nodes = df_nodes.vstack(
        pl.DataFrame({
            "id": [6],
            "doc_id": [1],
            "paragraph_id": [1],
            "sentence_id": [1],
            "sentence": ["This is a test."],
            "token_id": [6],
            "token": [None],
            "lemma": ["vu"],
            "upos": ["VERB"],
            "xpos": ["."],
            "feats": ["Gender=Male"],
            "head_token_id": [1],
            "dep_rel": ["TEST"],
            "deps": [""],
            "misc": ["test misc F"],
        })
    )

    # Get the MFH value
    mfh, ph, dict_extra_info = get_mfh(
        sentences=None,
        df_nodes=df_nodes,
    )

    # Check that the MFH is still 1.0, since the None lemma should be excluded
    assert mfh == 1.0, f"Expected MFH to be 1.0, but got {mfh}"

    # Test 6. Add a seventh row with a None lemma. Should still be 1.0.
    df_nodes = df_nodes.vstack(
        pl.DataFrame({
            "id": [7],
            "doc_id": [1],
            "paragraph_id": [1],
            "sentence_id": [1],
            "sentence": ["This is a test."],
            "token_id": [7],
            "token": ["wu"],
            "lemma": [None],
            "upos": ["VERB"],
            "xpos": ["."],
            "feats": ["Gender=Female"],
            "head_token_id": [1],
            "dep_rel": ["TEST"],
            "deps": [""],
            "misc": ["test misc G"],
        })
    )

    # Get the MFH value
    mfh, ph, dict_extra_info = get_mfh(
        sentences=None,
        df_nodes=df_nodes,
    )

    # Check that the MFH is still 1.0, since the None lemma should be excluded
    assert mfh == 1.0, f"Expected MFH to be 1.0, but got {mfh}"

    # Test 7. A mix of all types of rows, with an entropy that isn't 0 or 1.
    df_nodes = pl.DataFrame({
        "id": [1, 2, 3, 4, 5, 6, 7, 8],
        "doc_id": [1, 1, 1, 1, 1, 1, 1, 1],
        "paragraph_id": [1, 1, 1, 1, 1, 1, 1, 1],
        "sentence_id": [1, 1, 1, 1, 1, 1, 1, 1],
        "sentence": ["This is a test."] * 8,
        "token_id": [1, 2, 3, 4, 5, 6, 7, 8],
        "token": ["123", "abc", "one", "", "tu", None, "wu", "extra"],
        "lemma": ["123", "abc", "one", "au", "", "vu", None, "extra"],
        "upos": ["NUM", "NOUN", "NUM", "VERB", "VERB", "VERB", "VERB", "VERB"],
        "xpos": ["N"] * 8,
        "feats": ["Gender=Male", "Gender=Female", "Gender=Male", "Gender=Female", "Gender=Male", "Gender=Female", "Gender=Male", "Gender=Female"],
        "head_token_id": [0, 1, 2, 3, 4, 5, 6, 7],
        "dep_rel": ["TEST"] * 8,
        "deps": [""] * 8,
        "misc": [f"test misc {x}" for x in "ABCDEFGH"],
    })

    # Get the MFH value
    mfh, ph, dict_extra_info = get_mfh(
        sentences=None,
        df_nodes=df_nodes,
    )

    # We expect the entropy to be greater than 0 but less than 1.
    assert 0.0 < mfh < 1.0, f"Expected MFH to be between 0.0 and 1.0, but got {mfh}"
    
    # It should have filtered out 5 rows (one number, two empty tokens, two empty lemmas)
    assert dict_extra_info["n_total_rows"] - dict_extra_info["n_total_rows_filtered"] == 5, \
        f"Expected 5 rows to be filtered out, but got {dict_extra_info['n_total_rows'] - dict_extra_info['n_total_rows_filtered']}"

def test_get_mfh_using_tsv():
    """
    Use test_01.tsv to test get_mfh function.
    """

    # Load output_test/processed_data/ud-treebanks-v2.14/test_01.tsv into a dataframe
    fpath_tsv = Path("code") / "output_test" / "processed_data" / "ud-treebanks-v2.14" / "test_01.tsv"
    df_nodes = pl.read_csv(
        str(fpath_tsv),
        separator="\t",
    )

    # Call get_mfh
    mfh, ph, dict_extra_info = get_mfh(
        sentences=None,
        df_nodes=df_nodes,
    )

    # Report the MFH value
    print(f"MFH for test_01.tsv: {mfh:.4f}")
    print(f"Filtered rows: {dict_extra_info['n_total_rows'] - dict_extra_info['n_total_rows_filtered']} out of {dict_extra_info['n_total_rows']} total rows.")