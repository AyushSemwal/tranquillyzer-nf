

process PREPROCESS {

    tag "${run_id}"
    label 'cpu'

    cpus params.preprocess_cpus
    container params.container_trq

    input:
    tuple val(run_id), path(raw_dir), path(work_dir)

    output:
    tuple val(run_id), path(work_dir)

    script:
    """
    mkdir -p ${work_dir}

    tranquillyzer preprocess \\
        ${raw_dir} \\
        ${work_dir} \\
        --output-base-qual \\
        --threads ${task.cpus}
    """
}