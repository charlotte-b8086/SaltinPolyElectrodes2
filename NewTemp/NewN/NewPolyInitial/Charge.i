##Setting up mesh
delta = '${delta}'
neg_delta = '${fparse -1*delta}'
one_plus_delta = '${fparse 1+delta}'
eps_sq = '${fparse eps*eps}'
eps_e_sq = '${fparse eps_e*eps_e}'

[Mesh]
  [electrode_0_mesh]
    type = GeneratedMeshGenerator
    dim = 1
    nx = '${nx_electrode}'
    xmin = '${neg_delta}'
    xmax = 0
  []
  [electrode_0_names]
    type = RenameBoundaryGenerator
    input = electrode_0_mesh
    old_boundary = 'left right'
    new_boundary = 'e0_left e0_right'
  []
  [electrode_0]
    type = RenameBlockGenerator
    input = electrode_0_names
    old_block = '0'
    new_block = '0'
  []

  [electrolyte_mesh]
    type = GeneratedMeshGenerator
    dim = 1
    nx = '${nx_electrolyte}'
    xmin = 0
    xmax = 1
  []
  [electrolyte_names]
    type = RenameBoundaryGenerator
    input = electrolyte_mesh
    old_boundary = 'left right'
    new_boundary = 'elyte_left elyte_right'
  []
  [electrolyte]
    type = RenameBlockGenerator
    input = electrolyte_names
    old_block = '0'
    new_block = '1'
  []

  [electrode_1_mesh]
    type = GeneratedMeshGenerator
    dim = 1
    nx = '${nx_electrode}'
    xmin = 1
    xmax = '${one_plus_delta}'
  []
  [electrode_1_names]
    type = RenameBoundaryGenerator
    input = electrode_1_mesh
    old_boundary = 'left right'
    new_boundary = 'e1_left e1_right'
 []
  [electrode_1]
    type = RenameBlockGenerator
    input = electrode_1_names
    old_block = '0'
    new_block = '2'
  []

  [stitch]
    type = StitchedMeshGenerator
    inputs = 'electrode_0 electrolyte electrode_1'
    stitch_boundaries_pairs = 'e0_right elyte_left; elyte_right e1_left'
    clear_stitched_boundary_ids = false
  []

  [rename_outer]
    type = RenameBoundaryGenerator
    input = stitch
    old_boundary = 'e0_left e1_right'
    new_boundary = 'left right'
  []

  [interface0]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'x=0'
    input = rename_outer
    new_sideset_name = 'interface0'
  []
  [interface1]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'x=1'
    input = interface0
    new_sideset_name = 'interface1'
  []
[]

[Variables]
  [./cp] #Concentration of cations
    order = FIRST
    family = LAGRANGE
    block = '1'
  [../]
  [./cn] #Concentration of anions 
    order = FIRST
    family = LAGRANGE
    block = '1'
  [../]
  [./cm] #Concentration of polymer
    order = FIRST
    family = LAGRANGE
    block = '1'
  [../]
  [./psi] #Electrolyte electrostatic potential 
    order = FIRST
    family = LAGRANGE
    block = '1'
  [../]
  [./rho_e] #Concentration of electrons
    order = FIRST
    family = LAGRANGE
    block = '0 2'
  [../]
  [./ci] #Concentration of intercalated metal
    order = FIRST
    family = LAGRANGE
    block = '0 2'
  [../]
  [./psi_e] #Electrode electrostatic potential
    order = FIRST
    family = LAGRANGE
    block = '0 2'
  [../]
[]

[AuxVariables]
  [./grad_cp]
    order = CONSTANT
    family = MONOMIAL
    block = '1'
  [../]
  [./grad_cn]
    order = CONSTANT
    family = MONOMIAL
    block = '1'
  [../]
  [./grad_cm]
    order = CONSTANT
    family = MONOMIAL
    block = '1'
  [../]
  [./grad_psi]
    order = CONSTANT
    family  = MONOMIAL
    block = '1'
  [../]
  [./grad_rho]
    order = CONSTANT
    family = MONOMIAL
    block = '0 2'
  [../]
  [./grad_ci]
    order = CONSTANT
    family = MONOMIAL
    block = '0 2'
  [../]
  [./grad_psi_e]
    order = CONSTANT
    family = MONOMIAL
    block = '0 2'
  [../]
  [./cp_ODE]
    order = CONSTANT
    family = MONOMIAL
    block = '1'
  [../]
  [./cn_ODE]
    order = CONSTANT
    family = MONOMIAL
    block = '1'
  [../]
  [./cm_ODE]
    order = CONSTANT
    family = MONOMIAL
    block = '1'
  [../]
  [./rho_ODE]
    order = CONSTANT
    family = MONOMIAL
    block = '0 2'
  [../]
  [./ci_ODE]
    order = CONSTANT
    family = MONOMIAL
    block = '0 2'
  [../]
[]

[AuxKernels]
  [./grad_cp_aux]
    type = VariableGradientComponent
    variable = grad_cp
    component = x
    gradient_variable = cp
  [../]
  [./grad_cn_aux]
    type = VariableGradientComponent
    variable = grad_cn
    component = x
    gradient_variable = cn
  [../]
  [./grad_cm_aux]
    type = VariableGradientComponent
    variable = grad_cm
    component = x
    gradient_variable = cm
  [../]
  [./grad_psi_aux]
    type = VariableGradientComponent
    variable = grad_psi
    component = x
    gradient_variable = psi
  [../]
  [./grad_rho_aux]
    type = VariableGradientComponent
    variable = grad_rho
    component = x
    gradient_variable = rho_e
  [../]
  [./grad_ci_aux]
    type = VariableGradientComponent
    variable = grad_ci
    component = x
    gradient_variable = ci 
  [../]
  [./grad_psi_e_aux]
    type = VariableGradientComponent
    variable = grad_psi_e
    component = x
    gradient_variable = psi_e 
  [../]
  [./cp_ODE_aux]
    type = ParsedAux
    variable = cp_ODE
    coupled_variables = 'cp cn cm grad_cp grad_cn grad_cm grad_psi'
    expression = '(1+cp/(sqrt(1e-1+(1-cp-cn-cm)^2)))*grad_cp + cp * grad_psi + (cp/(sqrt(1e-1+(1-cp-cn-cm)^2)))*(grad_cn + grad_cm)'
  [../]
  [./cn_ODE_aux]
    type = ParsedAux
    variable = cn_ODE
    coupled_variables = 'cp cn cm grad_cp grad_cn grad_cm grad_psi'
    expression = '(1+cn/(sqrt(1e-1+(1-cp-cn-cm)^2)))*grad_cn - cn * grad_psi + (cn/(sqrt(1e-1+(1-cp-cn-cm)^2)))*(grad_cp + grad_cm)'
  [../]
  [./cm_ODE_aux]
    type = ParsedAux
    variable = cm_ODE
    coupled_variables = 'cp cn cm grad_cp grad_cn grad_cm'
    expression = '(1/${N}+${rho_M}*cm/sqrt(1e-1+(1-cp-cn-cm)^2))*grad_cm +${rho_M}* (cm/(sqrt(1e-1+(1-cp-cn-cm)^2)))*(grad_cp + grad_cn)'
  [../]
  [./rho_ODE_aux]
    type = ParsedAux
    variable = rho_ODE
    coupled_variables = 'rho_e grad_rho grad_psi_e'
    expression = 'grad_rho - rho_e * grad_psi_e'
  [../]
  [./ci_ODE_aux]
    type = ParsedAux
    variable = ci_ODE
    coupled_variables = 'ci grad_ci'
    expression = '(1/sqrt(1e-1+(1-ci)^2))*grad_ci'
  [../]
[]

[ICs]
  [./cp]
    type = ConstantIC 
    variable = cp
    value = 0.14645
  [../]
  [./cn]
    type = ConstantIC 
    variable = cn
    value = 0.14645
  [../]
  [./cm]
    type = ConstantIC
    variable = cm
    value = 0.14645
  [../]
  [./rho_e]
    type = ConstantIC
    variable = rho_e
    value = 1.5
  [../]
  [./ci]
    type = ConstantIC
    variable = ci
    value = 0.6
  [../]
[]

[Functions]
[]

[BCs]
  [./psi_e_dirichlet]
    type = ADDirichletBC
    variable = psi_e
    boundary = 'left'
    value = 0
  [../]
  [./potential_matched_value]
    type = ADMatchedValueBC
    variable = psi
    v = psi_e
    boundary = 'interface1 interface0'
  [../]
  [./e_neumann_left]
    type = ADNeumannBC
    variable = rho_e
    boundary = 'left'
    value =  '${fparse -I}'
  [../]
  [./e_neumann_right]
    type = ADNeumannBC
    variable = rho_e
    boundary = 'right'
    value = '${I}' 
  [../]
[]

[Constraints]
[]

[InterfaceKernels]
  [./electric_field_interface_flux_match]
    type = InterfaceDiffusionFluxMatch
    boundary = 'interface0 interface1'
    variable = psi_e 
    neighbor_var = psi
    D = '${eps_e_sq}'
    D_neighbor = '${eps_sq}'
  [../]
  [./pe_flux]
    type = CustomSpeciesInterfaceFlux
    boundary = 'interface0 interface1'
    variable = rho_e
    neighbor_var = cp
    metal_var = ci
    n_var = cn
    m_var = cm
    I_ex = '${I_ex}'
  [../]
  [./i_flux]
    type = CustomSpeciesInterfaceFluxI
    boundary = 'interface0 interface1'
    variable = ci
    neighbor_var = cp
    e_var = rho_e
    n_var = cn
    m_var = cm
    alpha = '${rho_I}'
    I_ex = '${I_ex}' 
  [../]
[]

[Materials]  
  [cation_diff]
    type              = ADParsedMaterial
    coupled_variables = 'cp cn cm'
    expression        = '${D_p}*(1+cp/(sqrt(1e-1+(1-cp-cn-cm)^2)))'
    property_name     = Dp
    block = '1'
  []
  [anion_diff]
    type              = ADParsedMaterial
    coupled_variables = 'cp cn cm'
    expression        = '${D_n}*(1+cn/(sqrt(1e-1+(1-cp-cn-cm)^2)))'
    property_name     = Dn
    block = '1'
  []
  [poly_diff]
    type              = ADParsedMaterial
    coupled_variables = 'cp cn cm'
    expression        = '${D_m}*(1/${N}+${rho_M}*cm/(sqrt(1e-1+(1-cp-cn-cm)^2)))'
    property_name     = Dm
    block = '1'
  []  
  [cation_crossdiff]
    type              = ADParsedMaterial
    coupled_variables = 'cp cn cm'
    expression        = '${D_p}*cp/sqrt(1e-1+(1-cp-cn-cm)^2)'
    property_name     = Dp_crossdiff
    block             = '1'
  []
  [anion_crossdiff]
    type              = ADParsedMaterial
    coupled_variables = 'cp cn cm'
    expression        = '${D_n}*cn/sqrt(1e-1+(1-cp-cn-cm)^2)'
    property_name     = Dn_crossdiff
    block             = '1'
  []
  [poly_crossdiff]
    type              = ADParsedMaterial
    coupled_variables = 'cp cn cm'
    expression        = '${D_m}*${rho_M}*cm/sqrt(1e-1+(1-cp-cn-cm)^2)'
    property_name     = Dm_crossdiff
    block             = '1'
  []
  [cation_electrodiffusivity]
    type = ADParsedMaterial
    coupled_variables = 'cp'
    expression = '${D_p}*cp'
    property_name = cation_electrodiff
    block = '1'
  []
  [anion_electrodiffusivity]
    type = ADParsedMaterial
    coupled_variables = 'cn'
    expression = '-${D_n}*cn'
    property_name = anion_electrodiff
    block = '1'
  []
  [electron_diffusivity]
    type = ADParsedMaterial
    expression = '${D_e}'
    property_name = De
  []
  [electron_electrodiffusivity]
    type = ADParsedMaterial
    coupled_variables = 'rho_e'
    expression = '-${D_e}*rho_e'
    property_name = electron_electrodiff
    block = '0 2'
  []
  [i_diffusivity]
    type = ADParsedMaterial
    coupled_variables = 'ci'
    #expression = '${D_i}/((1-ci))'
    expression = '${D_i}/sqrt(1e-1+(1-ci)^2)'
    property_name = Di
    block = '0 2'
  []
  [eps_sq]
    type = ADParsedMaterial
    expression = '${eps}*${eps}'
    property_name = eps_sq
  []
  [eps_e_sq]
    type = ADParsedMaterial
    expression = '${eps_e}*${eps_e}'
    property_name = eps_e_sq
  []
[]

[Kernels]
  #R_cp  (dcp/dt, test) + (D_p (nabla cp + cp nabla psi), nabla test) - <D_p (nabla cp + cp nabla psi) cdot n, test> = 0
  [./cp_time_deriv]
    variable = cp 
    type = ADTimeDerivative
  [../]
  [./cp_diffusion]
    variable = cp 
    type = ADMatDiffusion
    diffusivity = Dp
  [../]
  [./cp_electrodiffusion]
    variable = cp 
    type = ADMatDiffusion
    diffusivity = cation_electrodiff
    v = psi
  [../]
  [./cp_crossdiff1]
    variable = cp
    type = ADMatDiffusion
    diffusivity = Dp_crossdiff
    v = cn
  [../]
  [./cp_crossdiff2]
    variable = cp
    type = ADMatDiffusion
    diffusivity = Dp_crossdiff
    v = cm
  [../]
  #R_cn
  [./cn_time_deriv]
    variable = cn
    type = ADTimeDerivative
  [../]
  [./cn_diffusion]
    variable = cn 
    type = ADMatDiffusion
    diffusivity = Dn
  [../]
  [./cn_electrodiffusion]
    variable = cn 
    type = ADMatDiffusion
    diffusivity = anion_electrodiff
    v = psi
  [../]
  [./cn_crossdiff1]
    variable = cn 
    type = ADMatDiffusion
    diffusivity = Dn_crossdiff
    v = cp
  [../]
  [./cn_crossdiff2]
    variable = cn 
    type = ADMatDiffusion
    diffusivity = Dn_crossdiff
    v = cm
  [../]
  #R_cm
  [./cm_time_deriv]
    variable = cm
    type = ADTimeDerivative
  [../]
  [./cm_diffusion]
    variable = cm 
    type = ADMatDiffusion
    diffusivity = Dm
  [../]
  [./cm_crossdiff1]
    variable = cm
    type = ADMatDiffusion
    diffusivity = Dm_crossdiff
    v = cn
  [../]
  [./cm_crossdiff2]
    variable = cm 
    type = ADMatDiffusion
    diffusivity = Dm_crossdiff
    v = cp
  [../]
  #R_psi (eps^2 nabla psi, nabla test) - <eps^2 dpsi/dn, test> - (0.5 cp, test) - (-rho_m/rho_p phi_m_ref, test)= 0
  [./psi_diffusion]
    variable = psi 
    type = ADMatDiffusion
    diffusivity = eps_sq
  [../]
  [./cation_force]
    variable = psi 
    type = ADCoupledForce
    v = cp
    coef = 0.5
  [../]
  [./anion_force]
    variable = psi
    type = ADCoupledForce
    v = cn
    coef = -0.5 
  [../]
  #R_rho_e: (drho_e/dt, test) + (D_e (nabla rho_e - rho_e nabla psi_e), nabla test) - <D_e (drho_e/dn - rho_e dpsi_e/dn)> = 0
  #boundary term is -4j
  [./rho_e_time_deriv]
    variable = rho_e 
    type = ADTimeDerivative
  [../]
  [./rho_e_diffusion]
    variable = rho_e 
    type = ADMatDiffusion
    diffusivity = De
  [../]
  [./rho_e_electrodiffusion]
    variable = rho_e 
    type = ADMatDiffusion
    diffusivity = electron_electrodiff
    v = psi_e
  [../]
  #R_ci
  [./ci_time_deriv]
    variable = ci
    type = ADTimeDerivative
  [../]
  [./ci_diffusion]
    variable = ci
    type = ADMatDiffusion
    diffusivity = Di
  [../]
  #R_psi_e: (eps_e^2 nabla psi_e, nabla test) - <eps_e^2 dpsi_e/dn, test> -(-0.5 rho_e, test)= 0
  [./psi_e_diffusion]
    variable = psi_e 
    type = ADMatDiffusion
    diffusivity = eps_e_sq
  [../]
  [./electron_force]
    variable = psi_e 
    type = ADCoupledForce
    coef = -0.5
    v = rho_e
  [../]
  [./charge]
    variable = psi_e
    type = ADBodyForce
    value = 0.75 
  [../]
[]

[ScalarKernels]
[]

[Preconditioning]
  [./coupled]
    type = SMP 
    full = true
  [../]
[]

[Postprocessors]
  active = 'psi_0 psi_1 psi_e_0 psi_e_1 psi_e_left cp_0 cp_1 rho_e_0 rho_e_1 rho_e_left rho_e_right psi_e_right'
  #Check psi matching values at interfaces implemented
  [psi_0]
    type = PointValue
    variable = psi
    point = '0 0 0'
  []
  [psi_1]
    type = PointValue
    variable = psi
    point = '1 0 0'
  [] 
  [psi_e_0]
    type = PointValue
    variable = psi_e
    point = '0 0 0'
  []
  [psi_e_1]
    type = PointValue
    variable = psi_e
    point = '1 0 0'
  []
  #Check 0 Dirichlet BC implemented
  [psi_e_left]
    type = NodalVariableValue
    variable = psi_e
    nodeid= 0
    execute_on = 'INITIAL TIMESTEP_END'
  []
  #Check Reaction BC implemented
  [cp_0]
    type = PointValue
    variable = cp
    point = '0 0 0'
  []
  [cp_1]
    type = PointValue
    variable = cp
    point = '1 0 0'
  []
  [rho_e_0]
    type = PointValue
    variable = rho_e
    point = '0 0 0'
  []
  [rho_e_1]
    type = PointValue
    variable = rho_e
    point = '1 0 0'
  []
  #Check matching nu implemented
  [rho_e_left]
    type = NodalVariableValue
    variable = rho_e
    nodeid = 0
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [rho_e_right]
    type = PointValue
    variable = rho_e
    point = '${one_plus_delta} 0 0'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [psi_e_right]
    type = PointValue
    variable = psi_e
    point = '${one_plus_delta} 0 0'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[VectorPostprocessors]
  active = 'cp_sample cn_sample cm_sample rho_sample ci_sample psi_sample psi_e_sample dpsidx_sample dpsiedx_sample cp_gov_sample cn_gov_sample cm_gov_sample ci_gov_sample rho_gov_sample'
  [cp_sample]
    type     = NodalValueSampler 
    variable = cp 
    sort_by  = 'x'
    block = '1'
  []
  [cn_sample]
    type     = NodalValueSampler 
    variable = cn 
    sort_by  = 'x'
    block = '1'
  []
  [cm_sample]
    type     = NodalValueSampler 
    variable = cm
    sort_by  = 'x'
    block = '1'
  []
  [rho_sample]
    type     = NodalValueSampler 
    variable = rho_e 
    sort_by  = 'x'
    block = '0 2'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [ci_sample]
    type     = NodalValueSampler 
    variable = ci
    sort_by  = 'x'
    block = '0 2'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [psi_sample]
    type     = NodalValueSampler 
    variable = psi 
    sort_by  = 'x'
    block = '1'
  []
  [dpsidx_sample]
    type     = ElementValueSampler 
    variable = grad_psi 
    sort_by  = 'x'
    block = '1'
  []
  [psi_e_sample]
    type     = NodalValueSampler 
    variable = psi_e 
    sort_by  = 'x'
    block = '0 2'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [dpsiedx_sample]
    type     = ElementValueSampler 
    variable = grad_psi_e 
    sort_by  = 'x'
    block = '0 2'
  []
  [cp_gov_sample]
    type     = ElementValueSampler 
    variable = cp_ODE 
    sort_by  = 'x'
    block = '1'
  []
  [cn_gov_sample]
    type     = ElementValueSampler 
    variable = cn_ODE 
    sort_by  = 'x'
    block = '1'
  []
  [cm_gov_sample]
    type     = ElementValueSampler 
    variable = cm_ODE 
    sort_by  = 'x'
    block = '1'
  []
  [rho_gov_sample]
    type     = ElementValueSampler 
    variable = rho_ODE 
    sort_by  = 'x'
    block = '0 2'
  []
  [ci_gov_sample]
    type     = ElementValueSampler 
    variable = ci_ODE 
    sort_by  = 'x'
    block = '0 2'
  []
[]

[Executioner]
  type = Transient
  end_time = 500#260 
  dtmin = 1e-12
  dt    = 1.0 
#  [TimeStepper]
#    type = IterationAdaptiveDT
#    dt = 1e-4 
#    growth_factor = 1.2
#  [] 
  solve_type = NEWTON#PJFNK 
  #l_max_its = 30
  #nl_max_its = 200
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-10
  #l_abs_tol = 1e-7
  line_search = 'basic'#'none'
  #petsc_options = '-pc_svd_monitor'
  petsc_options_iname = '-pc_factor_shift_type -pc_type'# -sub_pc_type'# -snes_linesearch_damping'
  petsc_options_value = 'NONZERO lu'# lu'# 0.5'
  auto_preconditioning = TRUE
  automatic_scaling = TRUE
  #Steady state solve parameters
  steady_state_detection = TRUE
  steady_state_start_time = 3
#  [./Adaptivity]
#    max_h_level = 10
#    steps = 2 
#  [../]
[]

[Outputs]
  exodus = true
  console = true
  csv = true
  print_linear_residuals = false
[]

