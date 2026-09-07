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
  phiVM   = 0.5
  kDFN    = 5
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
  
  sigma = 1e-4#1e-3
  transferenceNo = 1.0#0.9   
 
  phiP    = phiSalt/(1+rhoP/rhoN)
  phiPoly = phiSalt*rhoP/rhoPoly 
  DpolyOverDp = (rhoP*phiP/(rhoPoly*phiPoly))*(1-transferenceNo)/transferenceNo
  Dp_dim = sigma*boltzmannConst*Temp/(elementaryUnitCharge**2) 
  Dp_dim = Dp_dim/(rhoP*phiP+rhoPoly*phiPoly*DpolyOverDp)
  Dpoly = DpolyOverDp*Dp_dim
  
  return dict(elementaryUnitCharge=elementaryUnitCharge, BjerrumLength=BjerrumLength,
              rhoP=rhoP, rhoN=rhoN, rhoI=rhoI, rhoPoly=rhoPoly,
              Dp_dim=Dp_dim, Dpoly=Dpoly, kDFN=kDFN,
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
  P['Dn'] = 0
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
