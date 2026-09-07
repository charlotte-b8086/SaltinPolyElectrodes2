import pandas as pd
import numpy as np

def softfloor(x):
  return 0.5 * (x + np.sqrt(x * x + 4.0 * 0.1 * 0.1))

def main():
  # Set param values
  eps  = 1.16e-5
  Dn   = 1
  Dm   =  1.74
  rhoM = 0.000118
  I_ex = 0.0170
  rhoN = 1.0
  Di   = 0.349
  I    = 0.000848
  De   = 174

  #Check electrostatic potential continuity at interfaces
  df = pd.read_csv("Charge_out.csv")
  cont0 = np.max(np.abs(df['psi_0']-df['psi_e_0']))
  cont1 = np.max(np.abs(df['psi_1']-df['psi_e_1']))
  print('Continuity at x = 0:', cont0)
  print('Continuity at x = 1:', cont1)
  print('psiL at x = -delta:', np.max(np.abs(df['psi_e_left'])), '\n')
 
  timeSteps = ["0000", "0001", "0002", "0003", "0004", "0005", "0006", "0007", "0008", "0009", "0010"]  

  #Check the species gov eqn.s 
  for idx in range(2, len(timeSteps)):
    dfcpOld = pd.read_csv(f'Charge_out_cp_sample_{timeSteps[idx-1]}.csv')
    dfcpNew = pd.read_csv(f'Charge_out_cp_sample_{timeSteps[idx]}.csv')
    dfcnOld = pd.read_csv(f'Charge_out_cn_sample_{timeSteps[idx-1]}.csv')
    dfcnNew = pd.read_csv(f'Charge_out_cn_sample_{timeSteps[idx]}.csv')
    dfcmOld = pd.read_csv(f'Charge_out_cm_sample_{timeSteps[idx-1]}.csv')
    dfcmNew = pd.read_csv(f'Charge_out_cm_sample_{timeSteps[idx]}.csv')
    
    dcpdt   = dfcpNew['cp']-dfcpOld['cp']
    dfcpgov = pd.read_csv(f'Charge_out_cp_gov_sample_{timeSteps[idx-1]}.csv')
    RHScp   = 1.0*np.diff(dfcpgov['cp_ODE'])/np.diff(dfcpgov['x'])
    dcndt   = dfcnNew['cn']-dfcnOld['cn']
    dfcngov = pd.read_csv(f'Charge_out_cn_gov_sample_{timeSteps[idx-1]}.csv')
    RHScn   = Dn*np.diff(dfcngov['cn_ODE'])/np.diff(dfcngov['x'])
    dcmdt   = dfcmNew['cm']-dfcmOld['cm']
    dfcmgov = pd.read_csv(f'Charge_out_cm_gov_sample_{timeSteps[idx-1]}.csv')
    RHScm   = Dm*np.diff(dfcmgov['cm_ODE'])/np.diff(dfcmgov['x'])

    checkXMscp = dfcpNew['x'].values[1:-1]-0.5*(dfcpgov['x'].values[1:]+dfcpgov['x'].values[0:-1])
    checkXMscn = dfcnNew['x'].values[1:-1]-0.5*(dfcngov['x'].values[1:]+dfcngov['x'].values[0:-1])
    checkXMscm = dfcmNew['x'].values[1:-1]-0.5*(dfcmgov['x'].values[1:]+dfcmgov['x'].values[0:-1])

    print('Checking cast xMs correctly:', np.max(np.abs(checkXMscp)), np.max(np.abs(checkXMscn)), np.max(np.abs(checkXMscm)))
    print('Checking electrolyte  gov eqns:', np.max(np.abs(dcpdt[1:-1]-RHScp)), np.max(np.abs(dcndt[1:-1]-RHScn)), np.max(np.abs(dcmdt[1:-1]-RHScm)))
    
    dfceOld = pd.read_csv(f'Charge_out_rho_sample_{timeSteps[idx-1]}.csv')
    dfceNew = pd.read_csv(f'Charge_out_rho_sample_{timeSteps[idx]}.csv')
    dfciOld = pd.read_csv(f'Charge_out_ci_sample_{timeSteps[idx-1]}.csv')
    dfciNew = pd.read_csv(f'Charge_out_ci_sample_{timeSteps[idx]}.csv')

    ceLOldmsk = dfceOld['x']<=0
    ceLNewmsk = dfceNew['x']<=0
    ceROldmsk = dfceOld['x']>=1
    ceRNewmsk = dfceNew['x']>=1
    dfceLOld = dfceOld[ceLOldmsk]
    dfceROld = dfceOld[ceROldmsk]
    dfceLNew = dfceNew[ceLNewmsk]
    dfceRNew = dfceNew[ceRNewmsk]
    ciLOldMsk = dfciOld['x']<=0
    ciLNewMsk = dfciNew['x']<=0
    ciROldMsk = dfciOld['x']>=1
    ciRNewMsk = dfciNew['x']>=1
    dfciLOld = dfciOld[ciLOldMsk]
    dfciROld = dfciOld[ciROldMsk]
    dfciLNew = dfciNew[ciLNewMsk]
    dfciRNew = dfciNew[ciRNewMsk]
    
    dceLdt   = dfceLNew['rho_e']-dfceLOld['rho_e']
    dceRdt   = dfceRNew['rho_e']-dfceROld['rho_e']
    dfcegov  = pd.read_csv(f'Charge_out_rho_gov_sample_{timeSteps[idx-1]}.csv')
    dfceLMsk = dfcegov['x']<=0
    dfceRMsk = dfcegov['x']>=1
    dfceLgov = dfcegov[dfceLMsk]
    dfceRgov = dfcegov[dfceRMsk]
    RHSceL   = De*np.diff(dfceLgov['rho_ODE'])/np.diff(dfceLgov['x'])
    RHSceR   = De*np.diff(dfceRgov['rho_ODE'])/np.diff(dfceRgov['x'])
    dciLdt   = dfciLNew['ci']-dfciLOld['ci']
    dciRdt   = dfciRNew['ci']-dfciROld['ci']
    dfcigov  = pd.read_csv(f'Charge_out_ci_gov_sample_{timeSteps[idx-1]}.csv')
    dfciLMsk = dfcigov['x']<=0
    dfciRMsk = dfcigov['x']>=1
    dfciLgov = dfcigov[dfciLMsk]
    dfciRgov = dfcigov[dfciRMsk]
    RHSciL   = Di*np.diff(dfciLgov['ci_ODE'])/np.diff(dfciLgov['x'])
    RHSciR   = Di*np.diff(dfciRgov['ci_ODE'])/np.diff(dfciRgov['x'])

    checkXLsce = dfceLNew['x'].values[1:-1]-0.5*(dfceLgov['x'].values[1:]+dfceLgov['x'].values[0:-1])
    checkXLsci = dfciLNew['x'].values[1:-1]-0.5*(dfciLgov['x'].values[1:]+dfciLgov['x'].values[0:-1])   
    checkXRsce = dfceRNew['x'].values[1:-1]-0.5*(dfceRgov['x'].values[1:]+dfceRgov['x'].values[0:-1])
    checkXRsci = dfciRNew['x'].values[1:-1]-0.5*(dfciRgov['x'].values[1:]+dfciRgov['x'].values[0:-1])   

    print('Checking cast xLs correctly:', np.max(np.abs(checkXLsce)), np.max(np.abs(checkXLsci)))
    print('checking left electrode  gov eqns:', np.max(np.abs(dceLdt[1:-1]-RHSceL)), np.max(np.abs(dciLdt[1:-1]-RHSciL)))
    print('Checking cast xRs correctly:', np.max(np.abs(checkXRsce)), np.max(np.abs(checkXRsci)))   
    print('checking right electrode  gov eqns:', np.max(np.abs(dceRdt[1:-1]-RHSceR)), np.max(np.abs(dciRdt[1:-1]-RHSciR)), '\n')

    print('Checking intercalated flux:', Di*dfciLgov['ci_ODE'].values[0], Di*dfciRgov['ci_ODE'].values[-1])
    print('Checking electron flux:', De*dfceLgov['rho_ODE'].values[0]-I, De*dfceRgov['rho_ODE'].values[-1]-I, '\n')

    cp0 = dfcpOld['cp'].values[0]
    cp1 = dfcpOld['cp'].values[-1]
    cn0 = dfcnOld['cn'].values[0]
    cn1 = dfcnOld['cn'].values[-1]
    cm0 = dfcmOld['cm'].values[0]
    cm1 = dfcmOld['cm'].values[-1]
    ce0 = dfceLOld['rho_e'].values[-1]
    ci0 = dfciLOld['ci'].values[-1]
    ce1 = dfceROld['rho_e'].values[0]
    ci1 = dfciROld['ci'].values[0]
    vm0 = softfloor(1-cp0-cn0-cm0)
    vm1 = softfloor(1-cp1-cn1-cm1)
    vl0 = softfloor(1-ci0)
    vr1 = softfloor(1-ci1)
    cp0, cp1, ce0, ci0, ce1, ci1 = softfloor(cp0), softfloor(cp1), softfloor(ce0), softfloor(ci0), softfloor(ce1), softfloor(ci1)
    R0 = I_ex*(np.exp(0.5)*np.sqrt(cp0*ce0*vl0/(ci0*vm0))-np.exp(-0.5)*np.sqrt(ci0*vm0/(cp0*ce0*vl0))) 
    R1 = I_ex*(np.exp(0.5)*np.sqrt(cp1*ce1*vr1/(ci1*vm1))-np.exp(-0.5)*np.sqrt(ci1*vm1/(cp1*ce1*vr1)))

    print('Checking no flux at interface:', Dn*dfcngov['cn_ODE'].values[0], Dn*dfcngov['cn_ODE'].values[-1], Dm*dfcmgov['cm_ODE'].values[0], Dm*dfcmgov['cm_ODE'].values[-1])
    print('Checking reaction at x = 0:', 1.0*dfcpgov['cp_ODE'].values[0]-R0, -De*dfceLgov['rho_ODE'].values[-1]-R0, -Di*dfciLgov['ci_ODE'].values[-1]+R0)
    print('Checking reaction at x = 1:',-1.0*dfcpgov['cp_ODE'].values[-1]-R1, De*dfceRgov['rho_ODE'].values[0]-R1,   Di*dfciRgov['ci_ODE'].values[0]+R1)
  for idx in range(1, len(timeSteps)):
    dfcp  = pd.read_csv(f'Charge_out_cp_sample_{timeSteps[idx]}.csv')
    dfcn  = pd.read_csv(f'Charge_out_cn_sample_{timeSteps[idx]}.csv')
    dfdpsidx = pd.read_csv(f'Charge_out_dpsidx_sample_{timeSteps[idx]}.csv')

    RHSpsi = 0.5*(dfcp['cp']-dfcn['cn'])
    LHSpsi = (eps)**2*(np.diff(dfdpsidx['grad_psi'])/np.diff(dfdpsidx['x']))

    checkXMs = 0.5*(dfdpsidx['x'].values[1:]+dfdpsidx['x'].values[0:-1])-dfcp['x'].values[1:-1]

    print('Checking cast xMs correctly:', np.max(np.abs(checkXMs)))
    print('Checking psiM gov eqn:', np.max(np.abs(LHSpsi-RHSpsi[1:-1])))

    dfce  = pd.read_csv(f'Charge_out_rho_sample_{timeSteps[idx]}.csv')
    dfdpsiedx = pd.read_csv(f'Charge_out_dpsiedx_sample_{timeSteps[idx]}.csv')
 
    ceLMsk = dfce['x']<=0
    ceRMsk = dfce['x']>=1
    dfceL = dfce[ceLMsk]
    dfceR = dfce[ceRMsk]
    psieLMsk = dfdpsiedx['x']<=0
    psieRMsk = dfdpsiedx['x']>=1
    dfdpsiLdx = dfdpsiedx[psieLMsk]
    dfdpsiRdx = dfdpsiedx[psieRMsk]

    RHSpsiL = 0.5*(1.5-dfceL['rho_e'])
    LHSpsiL = (eps)**2*(np.diff(dfdpsiLdx['grad_psi_e'])/np.diff(dfdpsiLdx['x']))
    RHSpsiR = 0.5*(1.5-dfceR['rho_e'])
    LHSpsiR = (eps)**2*(np.diff(dfdpsiRdx['grad_psi_e'])/np.diff(dfdpsiRdx['x']))

    checkXLs = 0.5*(dfdpsiLdx['x'].values[1:]+dfdpsiLdx['x'].values[0:-1])-dfceL['x'].values[1:-1]
    checkXRs = 0.5*(dfdpsiRdx['x'].values[1:]+dfdpsiRdx['x'].values[0:-1])-dfceR['x'].values[1:-1]

    print('Checking cast xLs correctly:', np.max(np.abs(checkXLs)))
    print('Checking psiL gov eqn:', np.max(np.abs(LHSpsiL-RHSpsiL[1:-1])))
    print('Checking cast xRs correctly:', np.max(np.abs(checkXRs)))
    print('Checking psiR gov eqn:', np.max(np.abs(LHSpsiR-RHSpsiR[1:-1])))
    print('dpsiR/dx at x = 1+deltaL', np.abs(dfdpsiRdx['grad_psi_e'].values[-1]))
    print('Grad psi match at interfaces', (eps**2)*(np.abs(dfdpsiLdx['grad_psi_e'].values[-1]-dfdpsidx['grad_psi'].values[0])), '\n')

if __name__ == "__main__":
    main()

