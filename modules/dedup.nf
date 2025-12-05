process DEDUP {

    tag "${run_id}"
    label 'cpu'

    cpus params.dedup_cpus
    container params.container_trq

    input:
    tuple val(run_id), path(work_dir), path(bam)

    output:
    tuple val(run_id), path(work_dir), path("${work_dir}/dedup/${run_id}.dedup.bam")

    script:
    """
    mkdir -p ${work_dir}/dedup

    # Adapt to your actual Tranquillyzer CLI as needed
    tranquillyzer dedup \\
        ${bam} \\
        --output-prefix ${work_dir}/dedup/${run_id} \\
        --threads ${task.cpus} \\
      > ${work_dir}/dedup/dedup.log 2>&1
    """
}