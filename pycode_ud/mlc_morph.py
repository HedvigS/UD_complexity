#!/usr/bin/env python3
# DOWNLOADED FROM https://github.com/coltekin/mcomplexity/blob/main/mlc-morph.py 2025-11-21
# EDITED FOR FIXES
from rich import print # EDIT
import polars as pl # EDIT
"""
"""

import sys
import os.path
from collections import Counter
import argparse
import numpy as np
from multiprocessing import Pool
import zlib
import random
import re
import glob

from pycode_ud.conllu import conllu_sentences






def score_file(fname, ctype='UD'):
    nodes = []
    if ctype == 'UD':
        for sent in conllu_sentences(fname):
            nodes.extend(sent.nodes[1:])
    else: # PBC
        # nodes = read_pbc(fname)
        raise NotImplementedError("PBC format not implemented")

    ttr = []
    msp = []
    pos_ent = []
    pos_count = []
    feat_ent = []
    feat_count = []
    cent_form_feat = []
    cent_feat_form = []

    if ctype != 'UD':
        msp = pe = pc = fe = fc = pos_ent = pos_count =\
        feat_ent = feat_count = form_feat = feat_form =\
        cent_form_feat = cent_feat_form = [0.0] * len(ttr)

    return fname, (ttr, msp, pe, pc, fe, fc, pos_ent, pos_count, feat_ent,
            feat_count, form_feat, feat_form, cent_form_feat, cent_feat_form)

# 
# fmt = "{}" + "{}{{}}".format(opt.separator) *16
# print("# sample_size = {}, samples = {}".format(
#     opt.sample_size, opt.samples))
# print(fmt.format('fname', 'ttr', 'ttr_sd', 'msp', 'msp_sd',
#     'pos_ent', 'pos_ent_sd', 'pos_types', 'pos_types_sd',
#     'feat_ent', 'feat_ent_sd', 'feat_types', 'feat_types_sd',
#     'cent_form_feat', 'cent_form_feat_sd',
#     'cent_feat_form', 'cent_feat_form_sd'), flush=True)
# 
# for fname, (ttr, msp, pe, pc, fe, fc, pos_ent, pos_count, feat_ent, feat_count, form_feat, feat_form, cent_form_feat, cent_feat_form) in res:
#     print(fmt.format(os.path.basename(fname).replace('.conllu', ''),
#                      np.mean(ttr), np.std(ttr),
#                      np.mean(msp), np.std(msp),
#                      np.mean(pos_ent), np.std(pos_ent),
#                      np.mean(pos_count), np.std(pos_count),
#                      np.mean(feat_ent), np.std(feat_ent),
#                      np.mean(feat_count), np.std(feat_count),
#                      np.mean(cent_form_feat), np.std(cent_form_feat), 
#                      np.mean(cent_feat_form), np.std(cent_feat_form)),
#                      flush=True)
# 
# nodes = []
# for sent in conllu_sentences(opt.files[0]):
#     nodes.extend(sent.nodes[1:])
# smpl = sample(nodes, opt.sample_size)
# juola_complexity(nodes)

def read_treebank(tbdir):
    sentences = []
    for tbf in glob.glob(tbdir + '/*.conllu'):
        sentences.extend(conllu_sentences(tbf))
    return sentences


def sample_nodes(sentences, sample_size=1000, random_sample=True,
        filter_num=True, filter_pos={'X', 'PUNCT'}, return_extra_info=False):
    """ Filter/sample sentences from given treebank sentences.

    Arguments:
    sample_size:    The size of the samples in number of nodes. If None (or
                    anything that evaluates to False, the whole
                    corpus is used.
    random_sample:  Sample formed by chosing sentences randomly
                    with replacement.  The order within the sentences
                    are preserved. If False, the order is not reandomized.
    filter_pos:     Set of POS tags to skip while creating the
                    node list.
    filter_num:     Skip the numbers (if written as arabic numerals).
    return_extra_info:  If True, return extra information about the sampling process. FIX.

    """

    # FIX
    # Sanity check
    if (not sample_size) and (random_sample):
        raise ValueError("It doesn't make sense to have random_sample==True "
                         "and sample_size==False.")

    # FIX
    # Create a copy of sentences. We will remove any sentences from this copy
    # that are discovered to have no valid nodes to sample.
    # That way, we will be able to reach sample_size (with replacement)
    # much more quickly.
    # And if it turns out that all sentences are removed, we can raise an error.
    sentences = sentences.copy()
    sentence_indices_sampled = set()
    dict_extra_info = {
        "n_total_sentences": len(sentences),
        "n_unique_sentences_used": 0,
        "n_filtered_pos": 0,
        "n_filtered_num": 0,
        "n_filtered_form_lemma": 0,
    }

    nodes = []
    i = -1
    # print("[yellow]SAMPLING NODES...[/yellow]") # FIX DEBUG
    while not sample_size or len(nodes) < sample_size:
        if random_sample:
            i = random.randrange(len(sentences))
        else:
            i = (i + 1) % len(sentences) # why? In case sample_size > len(sentences)*average nodes per sentence.
        # print(f"[yellow]Processing sentence {i} of {len(sentences)}...[/yellow]") # FIX DEBUG
        n_nodes_sampled = 0
        for n in sentences[i].nodes[1:]:
            if filter_pos and n.upos in filter_pos:
                dict_extra_info["n_filtered_pos"] += 1
                continue
            elif filter_num and n.upos == 'NUM' and not n.form.isalpha():
                dict_extra_info["n_filtered_num"] += 1
                continue
            elif n.form is None or n.lemma is None: # error in some treebanks
                dict_extra_info["n_filtered_form_lemma"] += 1
                continue
            nodes.append(n)
            n_nodes_sampled += 1
        
        # If no nodes were sampled from this sentence, remove it from the list.
        if n_nodes_sampled == 0:
            sentences.pop(i)
            i -= 1 # If random_sample is True, this doesn't matter. If False, we need to adjust i as we removed a sentence.
        else:
            sentence_indices_sampled.add(i)
        if len(sentences) == 0:
            break # FIX: all sentences filtered out
        if not sample_size and i == len(sentences): # this assumes random_sample==False
            break
    # print(f"[green]SAMPLED {len(nodes)} NODES.[/green]") # FIX DEBUG
    if sample_size and len(nodes) > sample_size: 
        nodes = nodes[:sample_size]

    if return_extra_info:
        dict_extra_info["n_unique_sentences_used"] = len(sentence_indices_sampled)
        return nodes, dict_extra_info
    else:
        return nodes

def get_ttr(sentences, sample_size=1000, random_sample=True,
        lowercase=True, filter_num=True, filter_pos={'X', 'PUNCT'},
        **kwargs):
    """ Calculate the type/token ratio on a sample of the given treebank.

    Arguments:
    lowercase:      Convert the words to lowercase.

    Other arguments are as defined in sample_nodes().

    Return value is the type/token ratio over the sample.
    """
    nodes = sample_nodes(sentences, sample_size=sample_size,
                 random_sample=random_sample,
                 filter_num=filter_num, filter_pos=filter_pos)


    if lowercase:
        words = [n.form.lower() for n in nodes]
    else:
        words = [n.form for n in nodes]
    return len(set(words)) / len(words)

def get_msp(sentences, sample_size=1000, random_sample=True,
        lowercase=True, filter_num=True, filter_pos={'X', 'PUNCT'},
        **kwargs):
    """ Calculate the 'mean size of paradigm' on a sample of the given treebank.

    Arguments:
    lowercase:      Convert the words to lowercase.

    Other arguments are as defined in sample_nodes().

    """
    nodes = sample_nodes(sentences, sample_size=sample_size,
                 random_sample=random_sample,
                 filter_num=filter_num, filter_pos=filter_pos)
    if lowercase:
        nlemmas = len(set((x.lemma.lower() for x in nodes)))
        nwords = len(set((x.form.lower() for x in nodes)))
    else:
        nlemmas = len(set((x.lemma for x in nodes)))
        nwords = len(set((x.form for x in nodes)))
    return (nwords / nlemmas)

def get_wh_lh(sentences, sample_size=1000, random_sample=True,
        lowercase=True, filter_num=True, filter_pos={'X', 'PUNCT'},
        smooth=None, **kwargs):
    """ Calculate the unigram words and lemma entropy.

    Arguments:
    lowercase:  Convert the words to lowercase.
    smooth:     Apply smoothing. A numeric value indicates 'add alpha'
                smoothing, 'GT' means absolute discouting based
                on Good-Tring. [these are currently not
                (re)implemented here as they are not used in the
                paper.]

    Other arguments are as defined in sample_nodes().

    """
    nodes = sample_nodes(sentences, sample_size=sample_size,
                 random_sample=random_sample,
                 filter_num=filter_num, filter_pos=filter_pos)
    if lowercase:
        clemmas = Counter((x.lemma.lower() for x in nodes))
        cwords = Counter((x.form.lower() for x in nodes))
    else:
        clemmas = Counter((x.lemma for x in nodes))
        cwords = Counter((x.form for x in nodes))
    nlemmas = sum(clemmas.values())
    nwords = sum(cwords.values())
    wh, lh = 0, 0
    for w in cwords:
        p = cwords[w] / nwords
        wh -= p * np.log2(p)
    for l in clemmas:
        p = clemmas[l] / nlemmas
        lh -= p * np.log2(p)
    return wh, lh

def get_mfh(sentences, sample_size=1000, random_sample=True,
        filter_num=True, filter_pos={'X', 'PUNCT'},
        smooth=None, df_nodes=None, return_distributions_only=False, **kwargs):
    """ Calculate the morphological feature (and POS) entropy.
    POS en

    Arguments:
    smooth:     Apply smoothing. A numeric value indicates 'add alpha'
                smoothing, 'GT' means absolute discouting based
                on Good-Tring. [these are currently not
                (re)implemented here as they are not used in the
                paper.]
    df_nodes:   Polars dataframe. If provided, use these nodes to calculate document
                frequencies for features. FIX.

    Other arguments are as defined in sample_nodes().
    """

    if df_nodes is None:
        # Original code.
        nodes, dict_extra_info = sample_nodes(sentences, sample_size=sample_size,
                    random_sample=random_sample,
                    filter_num=filter_num, filter_pos=filter_pos, return_extra_info=True)
        
        cfeat = Counter()
        cpos = Counter()
        npos, nfeat = 0, 0
        # print("[yellow]STEPPING THROUGH NODES...[/yellow]") # FIX DEBUG
        for node in nodes:
            if node.feats:
                feats = node.feats.split('|')
                cfeat.update(feats)
            cpos.update([node.upos])

    else:

        # Filter (a) empty tokens and lemmas and (b) numbers.
        # Original code in sample_nodes that does this (we assume n.form corresponds to the column "token" in the dataframe):
        # elif filter_num and n.upos == 'NUM' and not n.form.isalpha():
    #         dict_extra_info["n_filtered_num"] += 1
    #         continue
    #     elif n.form is None or n.lemma is None: # error in some treebanks
    #         dict_extra_info["n_filtered_form_lemma"] += 1
    #         continue

        dict_extra_info = {"from_dataframe": True}

        dict_extra_info["n_total_rows"] = df_nodes.height
        
        # Filter empty tokens and lemmas
        df_nodes = df_nodes.filter(
            (pl.col("token").is_not_null()) &
            (pl.col("lemma").is_not_null()) &
            (pl.col("token") != "") &
            (pl.col("lemma") != "")
        )

        # Filter empty nodes - where token id contains the literal character "."
        df_nodes = df_nodes.filter(
            ~pl.col("token_id").cast(pl.Utf8).str.contains(r"\.").fill_null(True)
        )

        # Filter numbers
        # The filter removes rows where upos == 'NUM' and token is not alphabetic (i.e. token.isalpha() is False).
        if filter_num:
            df_nodes = df_nodes.filter( # Keep only those rows...
                ~( # ...where it is NOT the case that...
                    (pl.col("upos") == "NUM") & # ...upos is NUM and...
                    (~pl.col("token").map_elements(lambda x: x.isalpha(), return_dtype=pl.Boolean)) # ...token is NOT alphabetic.
                )
            )
            
        dict_extra_info["n_total_rows_filtered"] = df_nodes.height
                
        cfeat = Counter()
        cpos = Counter()
        npos, nfeat = 0, 0
    
        # Each row should create a DotDict-like object with 'feats' and 'upos' attributes,
        # taken from the columns 'feats' and 'upos' of the dataframe.
        for row in df_nodes.iter_rows(named=True):
            # print(row) # FIX DEBUG
            # print(row['feats'])
            # print(row['upos'])
            if row['feats']:
                feats = row['feats'].split('|')
                cfeat.update(feats)

                # Track which features belong to which parts of speech.
                for feat in feats:
                    key = f"{row['upos']}__{feat.split('=')[0]}"
                    if key not in dict_extra_info:
                        dict_extra_info[key] = 0
                    dict_extra_info[key] += 1

            cpos.update([row['upos']])
    
    if return_distributions_only:
        return cfeat, cpos, dict_extra_info
    
    # Below here original code.
    npos = sum(cpos.values())
    nfeat = sum(cfeat.values())
    ph, mfh = 0, 0
    for pos in cpos:
        p = cpos[pos] / npos
        ph -= p * np.log2(p)
    for feat in cfeat:
        p = cfeat[feat] / nfeat
        mfh -= p * np.log2(p)
    return mfh, ph, dict_extra_info


def random_words(words, uniform=False):
    alphabet = {str(i):i for i in range(10)}
    if uniform:
        chcount = Counter(set((ch for w in words for ch in w)))
    else:
        chcount = Counter((ch for w in words for ch in w ))
    if len(chcount) > 256:
        # Non-alphabetic scripts are not comparable,
        # we calculate a value for the sake of robustness
        print("Warning: more than 255 characters", file=sys.stderr)
        chcount = Counter(dict(chcount.most_common(255)))
    n = sum(chcount.values())
    p = [chcount[i]/n for i in chcount]
    worddict = set(words)
    rdict = {w:''.join(np.random.choice(list(chcount), size=len(w),
                    replace=True, p=p)) for w in worddict}
    return [rdict[w] for w in words]

def get_ws(sentences, sample_size=1000, random_sample=True,
        lowercase=True, filter_num=True, filter_pos={'X', 'PUNCT'},
        **kwargs):
    """Calculate the information loss when word-internal structure is destroyed.

    Arguments:
    lowercase:  Convert the words to lowercase.

    Other arguments are as defined in sample_nodes().

    """
    nodes = sample_nodes(sentences, sample_size=sample_size,
                 random_sample=random_sample,
                 filter_num=filter_num, filter_pos=filter_pos)
    if lowercase:
        words = [n.form.lower() for n in nodes]
    else:
        words = [n.form for n in nodes]
    rwords = random_words(words)

    alphabet = {' ': 0}
    for w in rwords:
        for ch in w:
            if ch not in alphabet:
                alphabet[ch] = len(alphabet) 

    text = ' '.join(words)      # original text
    rtext = ' '.join(rwords)    # randomized `cooked' text
    # We binarize them to remove the effects of Unicode encoding
    bintext =  bytearray([alphabet.get(ch, 0) for ch in text])
    comptext = zlib.compress(bintext, level=9)
    cr = len(bintext)/len(comptext)
    rbintext =  bytearray([alphabet.get(ch, 1) for ch in rtext])
    rcomptext = zlib.compress(rbintext, level=9)
    rcr = len(rbintext)/len(rcomptext)
    return cr - rcr

def get_is(sentences, sample_size=1000, random_sample=True, 
        **kwargs): #ignore unsused arguments
    """Calculate maximum number of inflectional markers per verb.

    All arguments passed to sample_nodes().

    """
    nodes = sample_nodes(sentences, sample_size=sample_size,
                 random_sample=random_sample)
    fset = set()    # set of features
    fvset = set()   # set of feature-value pairs
    featcount = []  # number of features marked on each verb
    for node in nodes:
        if node.upos == 'VERB' and node.feats:
            fvlist = node.feats.split('|')
            fvset.update(fvlist)
            feats = (fv.split('=')[0] for fv in fvlist)
            fset.update(feats)
            featcount.append(len(fvlist))
    avg = 0
    if featcount:
        avg = sum(featcount)/len(featcount)
#    return len(fset), len(fvset), avg
    return len(fset)

def get_wh(*args, **kwargs):
    return get_wh_lh(*args, **kwargs)[0]

def get_lh(*args, **kwargs):
    return get_wh_lh(*args, **kwargs)[1]


if __name__ == '__main__':
    measures = {
        'ttr':  ('Type/token ratio', get_ttr), 
        'msp':  ('Means size of paradigm', get_msp), 
        'ws':   ('Word structure information', get_ws), 
        'wh':   ('Word entropy (unigram)', get_wh), 
        'lh':   ('Lemma entropy', get_lh), 
        'is':   ('Inflectional synthesis', get_is), 
        'mfh':  ('Morphological feature entropy', get_mfh),
    }


    ap = argparse.ArgumentParser()
    ap.add_argument('treebanks', nargs='+')
    ap.add_argument('-j', '--nproc', default=1, type=int,
                        help='number of processes')
    ap.add_argument('-s', '--samples', default=10, type=int,
                        help='number of samples')
    ap.add_argument('-S', '--sample-size', default=1000, type=int)
    ap.add_argument('--separator', default='\t')
    ap.add_argument('-n', '--normalize', action='store_true')
    ap.add_argument('-m', '--measures', default='all',
                        help='comma separated measures, or all')
    ap.add_argument('-o', '--output', default='measures.txt')
    args = ap.parse_args()

    if args.measures == 'all':
        mlist = tuple(measures.keys())
    else:
        mlist = args.measures.split(',')

    def get_score(jobdesc):
        func = measures[jobdesc[0]][1]
        tb = read_treebank(jobdesc[1])
        kwargs = jobdesc[2]
        return jobdesc, func(tb,**kwargs)

    kwargs = {'sample_size': args.sample_size}
    joblist = []
    for m in mlist:
        for tbdir in args.treebanks:
            for _ in range(args.samples):
                joblist.append((m, tbdir, kwargs))

    pool = Pool(processes=args.nproc)
    res = pool.map(get_score, joblist)

    scores = dict()
    for (m, tb, _), sc in res:
        tb = os.path.basename(tb.rstrip('/')).replace('UD_','')
        if (m, tb) not in scores:
            scores[(m, tb)] = []
        scores[(m, tb)].append(sc)

    tblist = [os.path.basename(tb.rstrip('/')).replace('UD_','') \
                for tb in args.treebanks]

    fmt = "\t{}" * (2*len(mlist))
    head = [x for pair in zip(mlist, (m + "_sd" for m in mlist)) for x in pair]
    with open(args.output, 'wt') as fp:
        print("treebank", fmt.format(*head), file=fp)
        for tb in tblist:
            print(tb, end="", file=fp)
            sclist = []
            for m in mlist:
                sc = np.array(scores[(m,tb)])
                sclist.extend((sc.mean(), sc.std()))
            print(fmt.format(*sclist), file=fp)
