# coding: utf-8
require "sam"
require "colorize"
require "crinja"
require "./utils/utils.cr"

desc "The CNF conformance suite checks to see if the CNFs are resilient to failures."
task "resilience", ["chaos_network_loss", "chaos_cpu_hog", "chaos_container_kill" ] do |t, args|
  VERBOSE_LOGGING.info "resilience" if check_verbose(args)
  VERBOSE_LOGGING.debug "resilience args.raw: #{args.raw}" if check_verbose(args)
  VERBOSE_LOGGING.debug "resilience args.named: #{args.named}" if check_verbose(args)
  stdout_score("resilience")
end

desc "Does the CNF crash when network loss occurs"
task "chaos_network_loss", ["install_chaosmesh", "retrieve_manifest"] do |_, args|
  task_response = task_runner(args) do |args|
    VERBOSE_LOGGING.info "chaos_network_loss" if check_verbose(args)
    config = CNFManager.parsed_config_file(CNFManager.ensure_cnf_conformance_yml_path(args.named["cnf-config"].as(String)))
    destination_cnf_dir = CNFManager.cnf_destination_dir(CNFManager.ensure_cnf_conformance_dir(args.named["cnf-config"].as(String)))
    deployment_name = config.get("deployment_name").as_s
    deployment_label = config.get("deployment_label").as_s
    helm_chart_container_name = config.get("helm_chart_container_name").as_s
    LOGGING.debug "#{destination_cnf_dir}"
    LOGGING.info "destination_cnf_dir #{destination_cnf_dir}"
    deployment = Totem.from_file "#{destination_cnf_dir}/manifest.yml"
    emoji_chaos_network_loss="📶☠️"

    errors = 0
    begin
      deployment_label_value = deployment.get("metadata").as_h["labels"].as_h[deployment_label].as_s
    rescue ex
      errors = errors + 1
      LOGGING.error ex.message 
    end
    if errors < 1
      template = Crinja.render(network_chaos_template, { "deployment_label" => "#{deployment_label}", "deployment_label_value" => "#{deployment_label_value}" })
      chaos_config = `echo "#{template}" > "#{destination_cnf_dir}/chaos_network_loss.yml"`
      VERBOSE_LOGGING.debug "#{chaos_config}" if check_verbose(args)
      run_chaos = `kubectl create -f "#{destination_cnf_dir}/chaos_network_loss.yml"`
      VERBOSE_LOGGING.debug "#{run_chaos}" if check_verbose(args)
      # TODO fail if exceeds
      if wait_for_test("NetworkChaos", "network-loss")
        LOGGING.info( "Wait Done")
        if desired_is_available?(deployment_name)
          resp = upsert_passed_task("chaos_network_loss","✔️  PASSED: Replicas available match desired count after network chaos test #{emoji_chaos_network_loss}")
        else
          resp = upsert_failed_task("chaos_network_loss","✖️  FAILURE: Replicas did not return desired count after network chaos test #{emoji_chaos_network_loss}")
        end
      else
        # TODO Change this to an exception (points = 0)
        # e.g. upsert_exception_task
        resp = upsert_failed_task("chaos_network_loss","✖️  FAILURE: Chaosmesh failed to finish.")
      end
      delete_chaos = `kubectl delete -f "#{destination_cnf_dir}/chaos_network_loss.yml"`
    else
      resp = upsert_failed_task("chaos_network_loss","✖️  FAILURE: No deployment label found for network chaos test")
    end
  end
end

desc "Does the CNF crash when CPU usage is high"
task "chaos_cpu_hog", ["install_chaosmesh", "retrieve_manifest"] do |_, args|
  task_response = task_runner(args) do |args|
    VERBOSE_LOGGING.info "chaos_cpu_hog" if check_verbose(args)
    config = CNFManager.parsed_config_file(CNFManager.ensure_cnf_conformance_yml_path(args.named["cnf-config"].as(String)))
    destination_cnf_dir = CNFManager.cnf_destination_dir(CNFManager.ensure_cnf_conformance_dir(args.named["cnf-config"].as(String)))
    deployment_name = config.get("deployment_name").as_s
    deployment_label = config.get("deployment_label").as_s
    helm_chart_container_name = config.get("helm_chart_container_name").as_s
    LOGGING.debug "#{destination_cnf_dir}"
    LOGGING.info "destination_cnf_dir #{destination_cnf_dir}"
    deployment = Totem.from_file "#{destination_cnf_dir}/manifest.yml"
    emoji_chaos_cpu_hog="📦💻🐷📈"

    errors = 0
    begin
      deployment_label_value = deployment.get("metadata").as_h["labels"].as_h[deployment_label].as_s
    rescue ex
      errors = errors + 1
      LOGGING.error ex.message 
    end
    if errors < 1
      template = Crinja.render(cpu_chaos_template, { "deployment_label" => "#{deployment_label}", "deployment_label_value" => "#{deployment_label_value}" })
      chaos_config = `echo "#{template}" > "#{destination_cnf_dir}/chaos_cpu_hog.yml"`
      VERBOSE_LOGGING.debug "#{chaos_config}" if check_verbose(args)
      run_chaos = `kubectl create -f "#{destination_cnf_dir}/chaos_cpu_hog.yml"`
      VERBOSE_LOGGING.debug "#{run_chaos}" if check_verbose(args)
      # TODO fail if exceeds
      if wait_for_test("StressChaos", "burn-cpu")
        if desired_is_available?(deployment_name)
          resp = upsert_passed_task("chaos_cpu_hog","✔️  PASSED: Application pod is healthy after high CPU consumption #{emoji_chaos_cpu_hog}")
        else
          resp = upsert_failed_task("chaos_cpu_hog","✖️  FAILURE: Application pod is not healthy after high CPU consumption #{emoji_chaos_cpu_hog}")
        end
      else
        # TODO Change this to an exception (points = 0)
        # e.g. upsert_exception_task
        resp = upsert_failed_task("chaos_cpu_hog","✖️  FAILURE: Chaosmesh failed to finish.")
      end
      delete_chaos = `kubectl delete -f "#{destination_cnf_dir}/chaos_cpu_hog.yml"`
    else
      resp = upsert_failed_task("chaos_cpu_hog","✖️  FAILURE: No deployment label found for cpu chaos test")
    end
  end
end

desc "Does the CNF recover when its container is killed"
task "chaos_container_kill", ["install_chaosmesh", "retrieve_manifest"] do |_, args|
  task_response = task_runner(args) do |args|
    VERBOSE_LOGGING.info "chaos_container_kill" if check_verbose(args)
    config = CNFManager.parsed_config_file(CNFManager.ensure_cnf_conformance_yml_path(args.named["cnf-config"].as(String)))
    destination_cnf_dir = CNFManager.cnf_destination_dir(CNFManager.ensure_cnf_conformance_dir(args.named["cnf-config"].as(String)))
    deployment_name = config.get("deployment_name").as_s
    deployment_label = config.get("deployment_label").as_s
    helm_chart_container_name = config.get("helm_chart_container_name").as_s
    LOGGING.debug "#{destination_cnf_dir}"
    LOGGING.info "destination_cnf_dir #{destination_cnf_dir}"
    deployment = Totem.from_file "#{destination_cnf_dir}/manifest.yml"
    emoji_chaos_container_kill="🗡️💀♻️"

    errors = 0
    begin
      deployment_label_value = deployment.get("metadata").as_h["labels"].as_h[deployment_label].as_s
    rescue ex
      errors = errors + 1
      LOGGING.error ex.message 
    end
    if errors < 1
      template = Crinja.render(chaos_template_container_kill, { "deployment_label" => "#{deployment_label}", "deployment_label_value" => "#{deployment_label_value}", "helm_chart_container_name" => "#{helm_chart_container_name}" })
      chaos_config = `echo "#{template}" > "#{destination_cnf_dir}/chaos_container_kill.yml"`
      VERBOSE_LOGGING.debug "#{chaos_config}" if check_verbose(args)
      run_chaos = `kubectl create -f "#{destination_cnf_dir}/chaos_container_kill.yml"`
      VERBOSE_LOGGING.debug "#{run_chaos}" if check_verbose(args)
      # TODO fail if exceeds
      if wait_for_test("PodChaos", "container-kill")
        CNFManager.wait_for_install(deployment_name, wait_count=60)
        if desired_is_available?(deployment_name)
          resp = upsert_passed_task("chaos_container_kill","✔️  PASSED: Replicas available match desired count after container kill test #{emoji_chaos_container_kill}")
        else
          resp = upsert_failed_task("chaos_container_kill","✖️  FAILURE: Replicas did not return desired count after container kill test #{emoji_chaos_container_kill}")
        end
      else
        # TODO Change this to an exception (points = 0)
        # e.g. upsert_exception_task
        resp = upsert_failed_task("chaos_container_kill","✖️  FAILURE: Chaosmesh failed to finish.")
      end
      delete_chaos = `kubectl delete -f "#{destination_cnf_dir}/chaos_container_kill.yml"`
    else
      resp = upsert_failed_task("chaos_container_kill","✖️  FAILURE: No deployment label found for container kill test")
    end
  end
end

desc "Does the CNF come back up when the pod is deleted"
task "pod-delete", ["install_litmus", "retrieve_manifest"] do |_, args|
  task_response = task_runner(args) do |args|
    config = CNFManager.parsed_config_file(CNFManager.ensure_cnf_conformance_yml_path(args.named["cnf-config"].as(String)))
    destination_cnf_dir = CNFManager.cnf_destination_dir(CNFManager.ensure_cnf_conformance_dir(args.named["cnf-config"].as(String)))
    deployment_name = config.get("deployment_name").as_s
    # deployment_label = config.get("deployment_label").as_s
    puts "#{destination_cnf_dir}"
    LOGGING.info "destination_cnf_dir #{destination_cnf_dir}"
    deployment = Totem.from_file "#{destination_cnf_dir}/manifest.yml"
    install_experiment = `kubectl apply -f https://raw.githubusercontent.com/litmuschaos/chaos-charts/master/charts/generic/pod-delete/experiment.yaml`
    install_rbac = `kubectl apply -f https://raw.githubusercontent.com/litmuschaos/chaos-charts/master/charts/generic/pod-delete/rbac.yaml`
    annotate = `kubectl annotate deploy/#{deployment_name} litmuschaos.io/chaos="true"`
    puts "#{install_experiment}" if check_verbose(args)
    puts "#{install_rbac}" if check_verbose(args)
    puts "#{annotate}" if check_verbose(args)
    # deployment_label_value = deployment.get("metadata").as_h["labels"].as_h[deployment_label].as_s

    chaos_experiment_name = "pod-delete"
    test_name = "#{deployment_name}-conformance-#{Time.local.to_unix}" 
    chaos_result_name = "#{test_name}-#{chaos_experiment_name}"

    template = Crinja.render(chaos_template_pod_delete, {"chaos_experiment_name"=> "#{chaos_experiment_name}", "test_name" => test_name})
    chaos_config = `echo "#{template}" > "#{destination_cnf_dir}/#{chaos_experiment_name}-chaosengine.yml"`
    puts "#{chaos_config}" if check_verbose(args)
    run_chaos = `kubectl apply -f "#{destination_cnf_dir}/#{chaos_experiment_name}-chaosengine.yml"`
    puts "#{run_chaos}" if check_verbose(args)

    describe_chaos_result = "kubectl describe chaosresults.litmuschaos.io #{chaos_result_name}"
    puts "initial checkin of #{describe_chaos_result}" if check_verbose(args)  
    puts `#{describe_chaos_result}` if check_verbose(args)  

    wait_count = 0 # going up to 20 mins so 20
    status_code = -1 # just a random number to start with
    verdict = ""
    verdict_cmd = "kubectl get chaosresults.litmuschaos.io #{chaos_result_name} -o jsonpath='{.status.experimentstatus.verdict}'" 
    puts "awating verdict of #{verdict_cmd}" if check_verbose(args)

    until (status_code == 0 && verdict != "Awaited") || wait_count >= 20
      sleep 60
      status_code = Process.run("#{verdict_cmd}", shell: true, output: verdict_response = IO::Memory.new, error: stderr = IO::Memory.new).exit_status 
      puts "status_code: #{status_code}" if check_verbose(args)  
      puts "verdict: #{verdict_response.to_s}"  if check_verbose(args)  
      verdict = verdict_response.to_s 
      wait_count = wait_count + 1
    end

    puts `#{describe_chaos_result}` if check_verbose(args)  

    if verdict == "Pass"
      resp = upsert_passed_task("pod-delete","✔️  PASSED: #{chaos_experiment_name} chaos test passed 🗡️💀♻️")
    else
      resp = upsert_failed_task("pod-delete","✖️  FAILURE: #{chaos_experiment_name} chaos test failed 🗡️💀♻️")
    end

    resp
  end
end


def network_chaos_template
  <<-TEMPLATE
  apiVersion: pingcap.com/v1alpha1
  kind: NetworkChaos
  metadata:
    name: network-loss
    namespace: default
  spec:
    action: loss
    mode: one
    selector:
      labelSelectors:
        '{{ deployment_label}}': '{{ deployment_label_value }}'
    loss:
      loss: '100'
      correlation: '100'
    duration: '40s'
    scheduler:
      cron: '@every 600s'
  TEMPLATE
end

def cpu_chaos_template
  <<-TEMPLATE
  apiVersion: pingcap.com/v1alpha1
  kind: StressChaos
  metadata:
    name: burn-cpu
    namespace: default
  spec:
    mode: one
    selector:
      labelSelectors:
        '{{ deployment_label}}': '{{ deployment_label_value }}'
    stressors:
      cpu:
        workers: 1
        load: 100
        options: ['-c 0']
    duration: '40s'
    scheduler:
      cron: '@every 600s'
  TEMPLATE
end

def chaos_template_container_kill
  <<-TEMPLATE
  apiVersion: pingcap.com/v1alpha1
  kind: PodChaos
  metadata:
    name: container-kill
    namespace: default
  spec:
    action: container-kill
    mode: one
    containerName: '{{ helm_chart_container_name }}'
    selector:
      labelSelectors:
        '{{ deployment_label}}': '{{ deployment_label_value }}'
    scheduler:
      cron: '@every 600s'
  TEMPLATE
end

def chaos_template_pod_delete
  <<-TEMPLATE
  apiVersion: litmuschaos.io/v1alpha1
  kind: ChaosEngine
  metadata:
    name:  {{ test_name }}
    namespace: default
  spec:
    jobCleanUpPolicy: 'retain'
    annotationCheck: 'true'
    engineState: 'active'
    #ex. values: ns1:name=percona,ns2:run=nginx 
    auxiliaryAppInfo: ''
    appinfo: 
      appns: 'default'
      applabel: run=coredns-coredns
      appkind: 'deployment'
    chaosServiceAccount: {{ chaos_experiment_name }}-sa 
    experiments:
      - name: {{ chaos_experiment_name }}
        spec:
          components:
            env:
              - name: TOTAL_CHAOS_DURATION
                value: '30'

              - name: CHAOS_INTERVAL
                value: '10'
                
              - name: FORCE
                value: 'false'
  TEMPLATE
  end
