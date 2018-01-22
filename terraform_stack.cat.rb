name 'Terraform Stack'
rs_ca_ver 20161221
short_description "![logo](https://avatars2.githubusercontent.com/u/11051457?v=4&s=64)

Deploy Terraform-defined infrastructure stack from a git repo with state preservation and audited workflow for centralized policy compliance"

long_description "### Description

This CloudApp provides state preservation, an audited workflow, and centralized policy compliance for an infrastructure stack defined in Terraform and stored in a Git repository.
    Creates: Linux Utility Server
    Requires: AWS Access Key & Secret via Credentials Or AzureRM Tenant Id, Client Id, Client Secret, and Subscription Id via Server Template Inputs.

---"

import "pft/server_templates_utilities", as: "rs_st"
import "pft/parameters"
import "pft/mappings"
import "pft/conditions"
import "pft/resources", as: "common_resources"

##################
# User inputs    #
##################

parameter "param_git_repo" do
  type "string"
  label "Git Repo"
  category "Settings"
  default "https://github.com/adamalex/terraform_sample.git"
end

parameter "param_branch_name" do
  type "string"
  label "Branch"
  category "Settings"
  default "master"
end

parameter "param_location" do
  like $parameters.param_location
end

parameter "param_instancetype" do
  like $parameters.param_instancetype
end

parameter "param_numservers" do
  like $parameters.param_numservers
end

parameter "param_costcenter" do
  category "Accounting"
  label "Cost Center"
  type "string"
  allowed_values "Development", "QA", "Production"
  default "Development"
  operations "launch"
end

################################
# Outputs returned to the user #
################################

output "out_last_ran" do
  label "Last Ran At"
  category "Terraform"
end

output "out_last_action" do
  label "Last Action"
  category "Terraform"
end

output "out_report" do
  label "Last Action Log"
  category "Terraform"
end

output "out_message" do
  label "Message"
  category "Terraform"
  default_value 'Ready to build the infrastructure for this stack. Use the action Terraform Plan to preview and validate what will be built, then Terraform Apply to build the infrastructure'
end

############################
# MAPPINGS                 #
############################

## In order for this CAT to compile, the parameters passed to map()
## must exist. When this package is consumed, the consuming CAT will
## redefine these

mapping "map_cloud" do
  like $mappings.map_cloud
end

mapping "map_instancetype" do
  like $mappings.map_instancetype
end

##################
# CONDITIONS     #
##################

# Used to decide whether or not to pass an SSH key or security group when creating the servers.
condition "needsSshKey" do
  like $conditions.needsSshKey
end

condition "needsSecurityGroup" do
  like $conditions.needsSecurityGroup
end

condition "needsPlacementGroup" do
  like $conditions.needsPlacementGroup
end

condition "invSphere" do
  like $conditions.invSphere
end

condition "inAzureRM" do
  like $conditions.inAzureRM
end

condition "inAWS" do
  like $conditions.inAWS
end

condition "inGoogle" do
  like $conditions.inGoogle
end

############################
# RESOURCE DEFINITIONS     #
############################

############################################################
### Security Group Definitions ###
# Note: Even though not all environments need or use security groups, the launch operation/definition will decide whether or not
# to provision the security group and rules.
resource "sec_group", type: "security_group" do
  condition $needsSecurityGroup
  like @common_resources.sec_group
end

resource "sec_group_rule_ssh", type: "security_group_rule" do
  condition $needsSecurityGroup
  like @common_resources.sec_group_rule_ssh
end

### SSH Key ###
resource "ssh_key", type: "ssh_key" do
  condition $needsSshKey
  like @common_resources.ssh_key
end

### Placement Group ###
resource "placement_group", type: "placement_group" do
  condition $needsPlacementGroup
  like @common_resources.placement_group
end

 resource 'utility', type: 'server', copies: $param_numservers do
  name join(['terr-',last(split(@@deployment.href,"/")), "-", copy_index()])
  cloud map($map_cloud, $param_location, "cloud")
  datacenter map($map_cloud, $param_location, "zone")
  network find(map($map_cloud, $param_location, "network"))
  subnets find(map($map_cloud, $param_location, "subnet"))
  instance_type map($map_instancetype, $param_instancetype, $param_location)
  ssh_key_href map($map_cloud, $param_location, "ssh_key")
  security_group_hrefs map($map_cloud, $param_location, "sg")
  placement_group_href map($map_cloud, $param_location, "pg")
  server_template find('Terraform', revision: "latest")
 end

####################
# OPERATIONS       #
####################

operation 'launch' do
  description 'Launch the application'
  definition 'launch'
end

operation 'terraform_plan' do
  label 'Terraform Plan'
  description 'Show execution plan for applying the current config'
  definition 'plan'
  output_mappings do {
    $out_report => $report,
    $out_last_action => 'Plan',
    $out_last_ran => $last_ran,
    $out_message => null
  } end
end

operation 'terraform_apply' do
  label 'Terraform Apply'
  description 'Apply the current configuration to the infrastructure'
  definition 'apply'
  output_mappings do {
    $out_report => $report,
    $out_last_action => 'Apply',
    $out_last_ran => $last_ran,
    $out_message => null
  } end
end

operation 'terraform_destroy' do
  label 'Terraform Destroy'
  description 'Destroy the infrastructure provisioned by the configuration'
  definition 'destroy'
  output_mappings do {
    $out_report => $report,
    $out_last_action => 'Destroy',
    $out_last_ran => $last_ran,
    $out_message => null
  } end
end

##########################
# DEFINITIONS (i.e. RCL) #
##########################

define launch($param_git_repo, $param_branch_name, $param_costcenter) do
  @@deployment.multi_update_inputs(inputs: {
    GIT_REPO: 'text:' + $param_git_repo,
    BRANCH_NAME: 'text:' + $param_branch_name,
    COST_CENTER: 'text:' + $param_costcenter
  })
end

define plan(@utility) return $report, $last_ran do
  call action(@utility, "plan") retrieve $report, $last_ran
end

define apply(@utility) return $report, $last_ran do
  call action(@utility, "apply") retrieve $report, $last_ran
end

define destroy(@utility) return $report, $last_ran do
  call action(@utility, "destroy") retrieve $report, $last_ran
end

define action(@utility, $action) return $report, $last_ran do
  call rs_st.run_script_inputs(@utility, "Terraform Execute", {
    TERRAFORM_ACTION: 'text:' + $action
  })

  $report = tag_value(@utility.current_instance(), "rs:terraform_out_url")
  $last_ran = strftime(now(), "%Y-%m-%d %H:%M:%S UTC")
end
