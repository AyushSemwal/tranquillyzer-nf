process DEDUP {

    tag "${sample_id}"
    label 'cpu'

    cpus params.dedup_cpus
    container params.container_trq

    input:
    tuple val(sample_id), path(work_dir), path(bam)

    output:
    tuple val(sample_id), path(work_dir), path("${work_dir}/aligned_files/${sample_id}_dup_marked.bam")

    script:
    """
    mkdir -p ${work_dir}/aligned_files
    # Adapt to your actual Tranquillyzer CLI as needed
    tranquillyzer dedup \\
        ${bam} \\
        --output-prefix ${work_dir}/aligned_files/${sample_id} \\
        --threads ${task.cpus} \\
      > ${work_dir}/dedup.log 2>&1
    """
}