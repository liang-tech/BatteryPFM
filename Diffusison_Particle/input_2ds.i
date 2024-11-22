# GlobalParams
#只计算区分颗粒中的浓度扩散---------------------------------------------------------------------------------------
#单位：um,s,g,pJ,fmol, kK
[GlobalParams]

[]

# ---------------------------------------------------------------------------------------
# Mesh
# ---------------------------------------------------------------------------------------
[Mesh]
    file = circle.msh
    dim = 2
[]

# ---------------------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------------------

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
    #initial_condition = 0.01
    #scaling = 1e2
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
    #initial_condition = -8
    #scaling = 1e-3
  [../]
[]

# ---------------------------------------------------------------------------------------
# ICs
# ---------------------------------------------------------------------------------------

[ICs]
[./IC_c]
    type = SpecifiedSmoothCircleIC
    3D_spheres = false
    variable = c
    invalue = 0.01
    outvalue = 0.96
    int_width = 0.01
    x_positions=' 0 '
    y_positions=' 0 '
    z_positions=' 0.0 '
    radii=' 0.13 '
  [../]
[]

# ---------------------------------------------------------------------------------------
# BCs
# ---------------------------------------------------------------------------------------
[BCs]
#  [./close_c]
#    type = NeumannBC   # DirichletBC   NeumannBC
#    variable = 'c'
#    boundary = 'CircleBoundary'
#    value = 0  #0.8
#  [../]
  [./fix_w]
    type = MatNeumannBC
    variable = 'w'
    boundary = 'CircleBoundary'
    boundary_material = 'M_c2'
    value = 1.45e-11
  [../]
[]

[Functions]


[]
# ---------------------------------------------------------------------------------------
# Kernels
# ---------------------------------------------------------------------------------------
[Kernels]
  [./W_I]
    variable = w
    v = c
    type = CoupledTimeDerivative
  [../]
  [./W_II]
    variable = w
    type = SplitCHWRes
    mob_name = M_c
#    args = 'c'
  [../]
  
  [./Rc]
    variable = c
    type = SplitCHParsed
    f_name = f_c
    kappa_name = kappa_c
    w = w
  [../]
[]


# ---------------------------------------------------------------------------------------
# Auxiliaries
# ---------------------------------------------------------------------------------------
[AuxVariables]

[]


[AuxKernels]

[]


# ---------------------------------------------------------------------------------------
# Materials
# ---------------------------------------------------------------------------------------

[Materials]
#----  Phase field  ----
  [./c_gradient]
    type = DerivativeParsedMaterial
    f_name = 'kappa_c'
    #args = 'T'
    constant_names =  'R  T   xmax  kappa0  d' 
    constant_expressions = '8.314  0.3  22.9  8.8e-6  1' 
    #material_property_names = ' idv_T:=idv_T(T) '
    function = 'R*T*xmax*kappa0*d' 
    derivative_order = 2
  [../]

  [./Diffusivity_c]
    type = DerivativeParsedMaterial
    f_name = 'M_c'
    args = 'c'
    constant_names = ' D_s   R   xmax   T   d'
    constant_expressions = ' 1e-3  8.314   22.9   0.3   1'
    #material_property_names = ' idv_s:=idv_s(rho)  dw_c:=dw_c(c) '
    function = '1*D_s/(R*T*xmax)*c*(1-c)/d'  #*c*(1-c)
    derivative_order = 1
  [../]
  [./Diffusivity_c2]
    type = DerivativeParsedMaterial
    f_name = 'M_c2'
    args = 'c'
    constant_names = ' D_s   R   xmax   T   d'
    constant_expressions = ' 1e-3  8.314   22.9   0.3   1'
    #material_property_names = ' idv_s:=idv_s(rho)  dw_c:=dw_c(c) '
    function = '1/( D_s/(R*T*xmax)*c*(1-c)/d +0.0000001 )'  #*c*(1-c)
    derivative_order = 1
  [../]
  
  [./local_energy_c]
    type = DerivativeParsedMaterial
    f_name = f_c
    args = 'c '
    constant_names = 'xmax   R   T   omega   d' 
    constant_expressions = '22.9   8.314  0.3  3.5   1'
    #material_property_names = ' idv_s:=idv_s(rho)  idv_T:=idv_T(T)  dw_phi:=dw_phi(rho)   W_phi:=W_phi(T) '
    function = 'd*xmax*R*T*(c*log(c)+(1-c)*log(1-c)+omega*c*(1-c))'
    derivative_order = 2
    #outputs = Outputs
  [../]

[]



# ---------------------------------------------------------------------------------------
# Postprocessors
# ---------------------------------------------------------------------------------------

[Postprocessors]
#  [./step_size]             # Size of the time step
#    type = TimestepSize
#  [../]
#  [./iterations]            # Number of iterations needed to converge timestep
#    type = NumNonlinearIterations
#  [../]
#  [./nodes]                 # Number of nodes in mesh
#    type = NumNodes
#  [../]
#  [./evaluations]           # Cumulative residual calculations for simulation
#    type = NumResidualEvaluations
#  [../]
#  [./active_time]           # Time computer spent on simulation
#    type = PerfGraphData
#    section_name = "Root"
#    data_type = total
#  [../]
  [./average]
    type = ElementAverageValue
    variable = c
  [../]
[]

# ---------------------------------------------------------------------------------------
# UserObjects
# ---------------------------------------------------------------------------------------

[UserObjects]

[]

# ---------------------------------------------------------------------------------------
# Executioner
# ---------------------------------------------------------------------------------------
[Executioner]
  type = Transient
  # scheme = bdf2 # Type of time integration (2nd order backward euler), defaults to 1st order backward euler
  solve_type = 'PJFNK'  # Preconditioned Jacobian-free Newton–Krylov
  #solve_type = 'NEWTON'
  l_max_its = 30   # Max Linear Iterations
  l_tol = 1e-7     # Linear Tolerance
  nl_max_its = 15  # Max Nonlinear Iterations
  nl_abs_tol = 1e-7 # Nonlinear Absolute Tolerance
  nl_rel_tol = 1e-6 # Nonlinear Relative Tolerance
  end_time = 2700
  #dt = 1
   [./TimeStepper]
     type = IterationAdaptiveDT
     dt = 10
  #   # dt_max = 10
  #   cutback_factor = 0.8
     growth_factor = 1.3
     optimal_iterations = 8
  [../]
[]

[Preconditioning]
  [./basic]
    type = SMP
    # type = FDP
    full = true
    petsc_options_iname = '-pc_type  -pc_factor_mat_solver_type -ksp_gmres_restart'
    petsc_options_value = ' lu        mumps              31'

  [../]

[]

#---------------------------------------------------------------------------------------
# Outputs
#---------------------------------------------------------------------------------------
[Outputs]
  csv = true
  # [./Outputs]
  #   # creates input_other.n
  #   type = Nemesis
  #   interval = 2
  #   file_base = 'output_nemesis'
  # [../]
  [./Outputs]
    # creates input_other.n
    type = Exodus
    interval = 8
  [../]
  #[./console]
  #  type = Console
  #  max_rows = 10
 # [../]
 # [./Checkpoint]
 #   type = Checkpoint
 #   num_files = 3
 #   interval = 20
 # [../]
[]

# ---------------------------------------------------------------------------------------
# Debug
# ---------------------------------------------------------------------------------------

[Debug]
  show_var_residual_norms = true
[]

