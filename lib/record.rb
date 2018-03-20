# frozen_string_literal: true

class Record
  def initialize(project, recommendation, instance)
    @recommendation = recommendation
    @instance = instance
    @project = project
  end

  def build
    reco_data = recommendation[:recommendation]
    target_info = recommendation[:targetInfo]
    reco_machine_type = reco_data[:recommendedMachineType]
    current_machine_type = target_info[:currentMachineType]
    labels = instance.labels || {}
    {
      "project": {
        "name": project.name,
        "id": project.project_id,
      },
      "vm": {
        "name": recommendation[:name],
        "zone": recommendation[:zone],
        "bosh": {
          "name": labels["name"],
          "job": labels["job"],
          "deployment": labels["deployment"],
          "instance_group": labels["instance_group"],
        },
        "estimated_cost_difference_per_month_in_cents_of_usd":
          to_cents(target_info[:estimatedCostDifferencePerMonthUsd]),
        "current_machine_type": {
          "cpu_milli_vcores": current_machine_type[:cpuMilliVcores],
          "memory_bytes": current_machine_type[:memoryBytes],
          "name": current_machine_type[:name],
          "reserved_cpu_milli_cores": current_machine_type[:reservedCpuMilliVcores],
        },
        "recommended_machine_type": {
          "cpu_milli_vcores": reco_machine_type[:cpuMilliVcores],
          "memory_bytes": reco_machine_type[:memoryBytes],
          "name": reco_machine_type[:name],
          "reserved_cpu_milli_cores": reco_machine_type[:reservedCpuMilliVcores],
        },
        "prediction": {
          "cpu_milli_vcores": reco_data[:predictedCpuMilliVcores],
          "memory_bytes": reco_data[:predictedMemoryBytes],
        },
      },
    }
  end

  private

  def to_cents(dollars)
    (BigDecimal(dollars.to_s) * 100).to_i
  end

  attr_reader :recommendation, :instance, :project
end
