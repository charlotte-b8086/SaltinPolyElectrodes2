import numpy as np

def compute_params(t0, N):
  # Constants
  elementaryUnitCharge = 1.602176634e-19
  boltzmannConst       = 1.380649e-23
  NA                   = 6.02214076e23
  vacuumPermittivity   = 8.8541878188e-12
  
  # System parameters
  Temp = 363.15 
  
  # Material parameters
  rI = 0.155e-9
  rP = rI
  rN = rP
  PEODensity = 1.26
  PEOMolecularWeight = 1e5
  phiSalt = 0.2929
  phiVM = 0.56065
  kDFN = 5
  epsM_dim, epsL_dim, epsR_dim = 10, 10, 10
  
  # Computations
  BjerrumLength = elementaryUnitCharge**2/(4*np.pi*boltzmannConst*Temp*vacuumPermittivity)
  
  rhoI = 1/((4/3)*np.pi*rI**3)
  rhoP = 1/((4/3)*np.pi*rP**3)
  rhoN = 1/((4/3)*np.pi*rN**3)
  
  rhoPoly = NA*PEODensity/PEOMolecularWeight
  rhoPoly = rhoPoly/(1e-6)
  
  nuP = 1/(1+rhoP/rhoN)
  nuN = 1/(1+rhoN/rhoP)
  
  m_molality = phiSalt/0.04405
  
  if m_molality <=3.18:
    sigma = (-3.5503e-4 + 2.5863e-3*m_molality + 3.5520e-4*m_molality**2  - 9.3371e-4*m_molality**3 + 1.9143e-4*m_molality**4)   
  else:
    sigma = (-0.031619 + 0.024055*m_molality - 6.2359e-3*m_molality**2+ 6.8038e-4*m_molality**3 - 2.6834e-5*m_molality**4) 
  
  sigma *=100
  print(sigma) 
  if t0:
    transferenceNo = (-28.534 + 17.881*m_molality - 4.0355*m_molality**2 + 0.39526*m_molality**3 - 0.014382*m_molality**4)
  else:
    transferenceNo = 0.5
  
  phiP = phiSalt/(1+rhoP/rhoN)
  phiN = (rhoP/rhoN)*phiP
  phiPoly = 1-phiP-phiN-phiVM
  Dp_dim = sigma*(transferenceNo/elementaryUnitCharge**2)*(boltzmannConst*Temp)* (transferenceNo/rhoP + (nuP/nuN)*(1-transferenceNo)/rhoN)
  coeff = rhoP*nuP/(rhoN*nuN)
  DnOverDp = (1-transferenceNo)/(transferenceNo*coeff)
  Dpoly = boltzmannConst*Temp/(N*(0.32e-11)*np.exp(phiSalt/0.085))
  
  return dict(elementaryUnitCharge=elementaryUnitCharge, BjerrumLength=BjerrumLength,
              rhoP=rhoP, rhoN=rhoN, rhoI=rhoI, rhoPoly=rhoPoly,
              Dp_dim=Dp_dim, DnOverDp=DnOverDp, Dpoly=Dpoly, kDFN=kDFN,
              epsM_dim=epsM_dim, epsL_dim=epsL_dim, epsR_dim=epsR_dim)
   
def build_params(delta, t0, N=10):
  c = compute_params(t0, N)

  P = {}
  L = 1e-6
  tau = L**2/c['Dp_dim']
  P['epsM'] = np.sqrt(c['epsM_dim']/(8*np.pi*c['BjerrumLength']*c['rhoP']))/L
  P['epsL'] = np.sqrt(c['epsL_dim']/(8*np.pi*c['BjerrumLength']*c['rhoP']))/L
  P['epsR'] = np.sqrt(c['epsR_dim']/(8*np.pi*c['BjerrumLength']*c['rhoP']))/L
  
  P['Dp'] = c['Dp_dim']*tau/L**2
  P['Dn'] = c['DnOverDp']*P['Dp']
  P['Dm'] = c['Dpoly']*tau/L**2
  P['rhoM'] = c['rhoPoly']/c['rhoP']
  P['I_ex'] = tau*c['kDFN']/(c['elementaryUnitCharge']*L*c['rhoP'])
  P['rhoP'] = c['rhoP']/c['rhoP']
  P['rhoN'] = c['rhoN']/c['rhoP']
  P['Di'] = tau*(1e-14)/L**2
  P['rhoI'] = c['rhoI']/c['rhoP']
  P['I'] = -0.25*tau/(L*c['rhoP']*c['elementaryUnitCharge'])
  P['De'] = 100*max(P['Dp'], P['Dn'], P['Di'], P['Dm'])
  
  P['L'] = L
  P['tau'] = tau
  return P

def main():
  P = build_params(2.0, 0, 1000)
  print(P)

if __name__ == "__main__":
    main() 
