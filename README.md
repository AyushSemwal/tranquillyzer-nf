# Tranquillyzer-nf

**Tranquillyzer-nf** is a reproducible **Nextflow DSL2** pipeline for running the **[Tranquillyzer](https://github.com/huishenlab/tranquillyzer.git)** long-read single-cell RNA-seq (scRNA-seq) processing workflow. It is designed to run with **Docker** or **Singularity/Apptainer**, on **HPC schedulers (e.g., SLURM)** and on GPU-capable compute environments.  

**Tranquillyzer (TRANscript QUantification In Long reads-anaLYZER)** is a flexible, architecture-aware deep learning framework for processing long-read scRNA-seq data. It performs structural annotation of reads (adapters / barcodes / UMIs / cDNA / polyT/A, etc.), supports custom library architectures via one-time model training, and scales to large datasets.  

- **Preprint**: *Tranquillyzer: A Flexible Neural Network Framework for Structural Annotation and Demultiplexing of Long-Read Transcriptomes*  
  bioRxiv 2025.07.25.666829  
  https://doi.org/10.1101/2025.07.25.666829

---

## Pipeline overview

This Nextflow pipeline orchestrates Tranquillyzer’s long-read scRNA-seq workflow end-to-end, including:

- **Preprocessing**
  - Read binning / chunking
  - Format conversion as required by Tranquillyzer
- **Read-length distribution** plotting
- **Read annotation and demultiplexing**
  - Structural annotation using Neural Network model
  - Barcode correction and cell assignment
- **Alignment and PCR duplicate marking / deduplication**
- **Splitting deduplicated BAMs** into individual cell (CBC) BAMs
- **Gene-level quantification**
  - Count matrix generation using **featureCounts (Subread)**

Planned / intended extensions:
- QC metrics aggregation and visualization
- Isoform-level quantification

---

## Requirements

### Core requirements
- **Nextflow** (recommended: ≥ 23.x)
- One of:
  - **Docker**
  - **Singularity / Apptainer**

### Compute notes
- Tranquillyzer’s **read annotation + demultiplexing** step can be GPU-accelerated.
- For HPC usage, ensure:
  - Access to GPU nodes (if using GPU annotation)
  - Apptainer/Singularity installed
  - A compatible CUDA stack (host-side)

---

## Quick start

### 1) Get the pipeline
```bash
git clone https://github.com/AyushSemwal/tranquillyzer-nf.git
cd tranquillyzer-nf
```

### 2) Configure execution via a params file
All execution behavior is controlled through a params config file (no need to switch profiles).

Key parameters you will typically set:
```groovy
params {
  executor         = 'local'             // 'local' or 'slurm'
  container_engine = 'docker'            // 'docker' | 'singularity' | 'apptainer'
  enable_gpu       = false               // true to enable GPU for GPU-labeled processes
}
```
Additional cluster- or environment-specific settings (optional):
```groovy
params {
  slurm_queue    = 'shen'
  slurm_time     = '48h'
  slurm_cpus     = 64
  slurm_gpu_opts = ''                    // e.g. '--gres=gpu:1'
}
```
Container runtime flags can be customized (or left blank):
```groovy
params {
  container_extra_opts = ''
}
```

### 3) Run the pipeline

Use the single default profile (standard) and point to your params file:
```groovy
nextflow run . \
  -profile standard \                   // or just blank
  -c conf/tests/params_10x3p.config \
  -resume
```

### Common usage patterns

#### Local run (GPU, Docker)
```groovy
params {
  executor         = 'local'
  container_engine = 'docker'
  enable_gpu       = true
}
```

#### HPC/SLURM run with GPU (Singularity/Apptainer)
```groovy
params {
  executor         = 'slurm'
  container_engine = 'singularity'
  enable_gpu       = true
}
```

## Notes & design principles
- No profile explosion: execution mode, container engine, and GPU usage are fully param-driven.
- GPU usage is selective: only processes labeled gpu receive GPU flags.
- featureCounts is always CPU-only and runs in the Subread container.
- Container flags are user-controlled via container_extra_opts.