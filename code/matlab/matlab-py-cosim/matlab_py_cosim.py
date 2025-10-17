import numpy as np
import S4


def calc_rspace():
    omegaSpace = np.linspace(0.25, 0.6, 351)
    RSpace = np.array(list(map(R_PhC_slab, omegaSpace)))
    return omegaSpace.tolist(), RSpace.tolist()  # 返回 list 给 MATLAB 方便处理


def R_PhC_slab(omega):
    """
    Define a function of S4 for calculating the reflectance of 2d PhC slabs.
    args:
        for the light: lda, wavelength;
        R: reflectance;
    """
    period = [1, 1]
    S = S4.New(Lattice=((period[0], 0), (0, period[1])), NumBasis=70)
    S.SetMaterial(Name="Air", Epsilon=(1 + 0j) ** 2)
    S.SetMaterial(Name="Dielectric", Epsilon=12 + 0j)

    S.AddLayer(Name="Air_layer", Thickness=0.1, Material="Air")
    S.AddLayer(Name="Dielectric_layer", Thickness=0.5, Material="Dielectric")
    S.SetRegionCircle(
        Layer="Dielectric_layer", Material="Air", Center=(0, 0), Radius=0.1
    )

    S.AddLayer(Name="Bottom_layer", Thickness=0.1, Material="Air")

    S.SetExcitationPlanewave(
        IncidenceAngles=(0, 0), sAmplitude=1, pAmplitude=0, Order=0
    )
    S.SetOptions(PolarizationDecomposition=True)
    S.SetFrequency(omega)
    powr1 = S.GetPowerFluxByOrder(Layer="Air_layer", zOffset=0)
    powr2 = S.GetPowerFluxByOrder(Layer="Bottom_layer", zOffset=0)

    R = np.abs(np.real(powr2[0][0])) / np.real(powr1[0][0])

    return R
