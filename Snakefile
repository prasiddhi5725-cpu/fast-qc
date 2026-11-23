import os

Threshold=config.get("threshold", 20)

plain=glob_wildcards("data/{sample}.fastq").sample
zipped=glob_wildcards("data/{sample}.fastq.gz").sample
Samples=sorted(set(plain)|set(zipped))

def get_fastq(wildcards):
    sample=wildcards.sample
    if sample in plain:
        return f"data/{sample}.fastq"
    elif sample in zipped:
        return f"data/{sample}.fastq.gz"
    else:
        raise ValueError(f"Sample {sample} not found in data directory.")

rule all:
    input:
        expand("results/{sample}_qc.txt", sample=Samples)

rule fastqc:
    input:
        fastq=get_fastq
    output:
        qc="results/{sample}_qc.txt",
        filtered="results/{sample}_filtered.fastq",
        quality_plot="results/{sample}_quality_plot.png",
        read_length_plot="results/{sample}_read_length_plot.png",
        gc_plot="results/{sample}_gc_plot.png"
    params:
        threshold=Threshold

    shell:
        "python program.py -i {input.fastq} -o {output.filtered} -t {params.threshold} --plot --prefix results/{wildcards.sample}_ > {output.qc}"