# MultiOptix 🌐🔬

**MultiOptix** is a modular simulation framework that bridges **macroscopic geometrical optics** and **microscopic nanophotonics** modeling. It is designed to facilitate system-level optical simulations that combine ray-tracing tools like **Zemax** with electromagnetic solvers such as **RCWA**, **FDTD**, and **FEM** — particularly for applications in **semiconductor metrology** and **advanced imaging systems**.

---

## 🔍 Motivation

In many real-world optical systems — such as overlay metrology in semiconductor manufacturing — the **optical system** is modeled using ray optics, while the **target/sample** must be rigorously analyzed using wave-based solvers.

⚠️ However, these two regimes are often simulated in isolation.  
✅ MultiOptix aims to unify them via a **seamless simulation pipeline**.

---

## 🧰 Key Features

- 📐 **Geometrical Optics Integration**
  - Ray-tracing via Zemax / Code V
  - System aperture, angle, and field distribution export
  
- 🌊 **Physical Optics Coupling**
  - RCWA/FDTD-based nanostructure modeling
  - Supports Lumerical, MEEP, or custom solvers

- 🔄 **Macro ↔ Nano Interface**
  - Ray bundles → field distributions
  - Far-field → near-field bridging
  - Wavelength/angle sweeping automation

- 📊 **Postprocessing & Analysis**
  - Overlay error simulation
  - Throughput & aberration-aware metrology predictions

---

## 🧱 Repository Structure

```bash
MultiOptix/
├── zemax/             # Zemax files & data export & processing
├── rcwa/              # RCWA integration layer or scripts (e.g., S4 or Ansys Lumerical RCWA)
├── fdtd/              # FDTD integration layer or scripts (e.g., MEEP or Ansys Lumerical FDTD)
├── examples/          # Sample projects, Python files and Jupyter notebooks
├── docs/              # Documentation and usage guide
└── README.md
```



