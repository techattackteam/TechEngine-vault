---

kanban-plugin: board

---

## TO VALIDATE 📋🤔

- [ ] https://dl.acm.org/doi/10.1145/324133.324234 - **Scheduling Multithreaded Computations by Work Stealing** | JACM 1999 (Multi-threading/task graph)
- [ ] https://www.gdcvault.com/play/1022186/Parallelizing-the-Naughty-Dog-Engine - **Parallelizing the Naughty Dog Engine Using Fibers** | GDC 2015 (Multi-threading/task graph)
- [ ] https://ieeexplore.ieee.org/document/6166348 - **A Design Pattern for Parallel Programming of Games** | IEEE TCIAIG 2012 (Multi-threading/task graph)
- [ ] https://dl.acm.org/doi/10.1145/301618.301633 - **Cache-Conscious Structure Layout** | PLDI 1999 (ECS)
- [ ] https://arxiv.org/abs/2606.14919 - **The Essence of Entity Component System** | ACM SAC 2026 (ECS)
- [ ] https://ieeexplore.ieee.org/document/7854097 - **Decoupling the Entity-Component-System Pattern using Semantic Traits for Reusable Realtime Interactive Systems** | IEEE SEARIS 2015 (ECS)
- [ ] https://arxiv.org/abs/2504.14815 - **A Mapping Study of the Entity Component System Pattern** | IEEE/ACM GAS 2025 (ECS)
- [ ] https://scholar.afit.edu/etd/5042/ - **Comparison of Archetypal Entity-Component Systems and Relational Databases** | AFIT 2021 (ECS)
- [ ] https://dl.acm.org/doi/10.1145/3152778 - **A Survey on Software Architectures for Game Engines** | ACM CIE 2017 (ECS)
- [ ] https://www.cs.ubc.ca/~pai/papers/KrySound01.pdf - **Continuous Contact Simulation for Sound** (Audio)
- [ ] http://graphics.cs.cmu.edu/projects/pat/ - **Precomputed Acoustic Transfer** | ACM SIGGRAPH 2006 (Audio)
- [ ] https://www.microsoft.com/en-us/research/publication/parametric-directional-coding-for-precomputed-sound-propagation/ - **Parametric Directional Coding for Precomputed Sound Propagation (Project Triton)** | ACM SIGGRAPH 2018 (Audio)
- [ ] https://gamma.cs.unc.edu/PrecompWave/ - **Precomputed Wave Simulation for Real-Time Sound Propagation** | ACM SIGGRAPH 2010 (Audio)
- [ ] https://gamma.cs.unc.edu/GSOUND/ - **GSound: Interactive Sound Propagation for Games** | AES 2011 (Audio)
- [ ] https://kunzhou.net/2016/sound-transport.pdf - **Bidirectional Sound Transport: Interactive Sound Propagation with Bidirectional Path Tracing** | ACM SIGGRAPH Asia 2016 (Audio)
- [ ] https://objf.ai/papers/Obrien-2002-SSF/Obrien-2002-SSF.pdf - **Synthesizing Sounds from Rigid-Body Simulations** | ACM SIGGRAPH / SCA 2002 (Audio)
- [ ] http://graphics.cs.cmu.edu/projects/shells/ - **Harmonic Shells: A Practical and High-Performance Method for Elastic Sound Synthesis** | ACM SIGGRAPH Asia 2012 (Audio)


## TO VALIDATE - MIGUEL REVIEW🔍

- [ ] https://graphics.stanford.edu/courses/cs468-03-winter/Papers/ibsrb.pdf - **Impulse-based Simulation of Rigid Bodies** | ACM I3D 1995 (Physics)
	Mirtich and Canny model every contact as collision impulses; background for the S1 lane, since Jolt will own the solver and TechEngine will not write one.
- [ ] https://www.cs.toronto.edu/~jacobson/seminar/mueller-et-al-2007.pdf - **Position Based Dynamics** | JVCIR 2007 (Physics)
	The original PBD paper, which projects constraints on positions directly; background for S1 and for Jolt's soft bodies, not something the engine will implement itself.
- [ ] http://mmacklin.com/smallsteps.pdf (Physics)
	**Small Steps in Physics Simulation**: fixed-step substeps and XPBD stability; useful for the planned physics lane.
- [ ] https://www.highperformancegraphics.org/previous/www_2012/media/Papers/HPG2012_Papers_Olsson.pdf (Rendering)
	**Clustered Deferred and Forward Shading**: light assignment for a future forward renderer.
- [ ] https://arxiv.org/abs/2011.05538 - **Sound Synthesis, Propagation, and Rendering: A Survey** | Survey preprint 2020 (Audio)
	Broad map of game and VR audio techniques before selecting specialized audio papers.
- [ ] https://research.nvidia.com/labs/prl/zesch2023ncf/neuralcollision2023.pdf - **Neural Collision Fields for Triangle Primitives** | SIGGRAPH Asia 2023 (Physics)
	A learned 6D field that integrates triangle-triangle contact instead of sampling contact points; background reading at most for S1, because Jolt owns collision and a neural primitive does not fit an authoritative fixed-step server.
- [ ] https://sites.google.com/view/diffsim/ (Physics) (Nao encontrei paper mas achei interessante)
	Could not resolve: the Google Sites page is blocked by this session's network policy, and web searches for the URL found no paper, title or authors behind it.
- [ ] https://developer.nvidia.com/gpugems/gpugems/part-vi-beyond-triangles/chapter-39-volume-rendering-techniques - **Volume Rendering Techniques** | GPU Gems 2004 (Rendering)
	A book chapter on texture-slice volume rendering of 3D data; background at most for R3's volumetric fog, which is more likely to march a froxel grid than to slice a volume texture.
- [ ] https://graphics.stanford.edu/papers/rigid_bodies-sig03/rigid_bodies.pdf - **Nonconvex Rigid Bodies with Stacking** | ACM SIGGRAPH 2003 (Physics)
	Guendelman, Bridson and Fedkiw stack nonconvex bodies with signed distance fields and shock propagation; background for S1, since Jolt owns contact and stacking.
- [ ] https://gamma.cs.unc.edu/BVH/ (Rendering)
	Could not resolve: the host is blocked by this session's network policy, and a web search found no paper behind the URL, only the GAMMA group's newer site at gamma.web.unc.edu.
- [ ] https://www.cs.cornell.edu/~srm/publications/EGSR07-btdf.pdf - **Microfacet Models for Refraction through Rough Surfaces** | EGSR 2007 (Rendering)
	The paper that introduced the GGX distribution and extended microfacet models to transmission; a direct reference for R1's material model, where GGX is the usual specular term.

- [ ] https://de45xmedrsdbp.cloudfront.net/Resources/files/TemporalAA_small-59732822.pdf - **High Quality Temporal Supersampling** | ACM SIGGRAPH 2014 Advances in Real-Time Rendering course (Rendering)
	Karis's talk slides on Unreal Engine 4's temporal anti-aliasing (jitter, reprojection, neighbourhood clamping); a direct reference if R2's post stack gets TAA. It is a talk, not a paper.
- [ ] https://www.di.ens.fr/~zappa/readings/ppopp13.pdf - **Correct and Efficient Work-Stealing for Weak Memory Models** | PPoPP 2013 (Multi-threading/task graph)
	Lê, Pop, Cohen and Zappa Nardelli prove an optimized Chase-Lev deque correct on ARM and POWER and give a C11 version; the reference for P2's work-stealing deque memory orders.
- [ ] https://dl.acm.org/doi/10.1145/1073970.1073974 - **Dynamic Circular Work-Stealing Deque** | SPAA 2005 (Multi-threading/task graph)
	Chase and Lev's growable circular work-stealing deque, the algorithm behind most job systems; the base design for P2's work-stealing, read together with the PPoPP 2013 paper on its memory orders.

## Rendering 👽



## Physics 🍎



## Multi-threading/task graph ➕

- [ ] [[Paper#Taskflow: A Lightweight Parallel and Heterogeneous Task Graph Computing System|Taskflow: A Lightweight Parallel and Heterogeneous Task Graph Computing System]]
- [ ] [[Paper#Exploring Scheduling Algorithms for Parallel Task Graphs: A Modern Game Engine Case Study|Exploring Scheduling Algorithms for Parallel Task Graphs: A Modern Game Engine Case Study]] | Euro-Par 2022 (Multi-threading/task graph)
	Scheduling measurements from game-engine task graphs; the reported gains come from a simulator.


## ECS 👻

- [ ] [[Paper#Exploring the Theory and Practice of Concurrency in the Entity-Component-System Pattern|Exploring the Theory and Practice of Concurrency in the Entity-Component-System Pattern]] | PACMPL / OOPSLA 2025 (ECS)
	Deterministic concurrent ECS systems; directly relevant to Scene and the parallel executor.


## Audio 🐄



## REJECTED

- [ ] https://doi.org/10.1109/IROS.2012.6386109 (Physics)
	**MuJoCo: A physics engine for model-based control**: MuJoCo is a generalized-coordinate engine built for robotics control and optimization, while S1 is Jolt running authoritative game physics in the fixed phase.
- [ ] https://arxiv.org/abs/2103.16021 (Physics)
	**Fast and Feature-Complete Differentiable Physics for Articulated Rigid Bodies with Contact**: Nimble makes DART differentiable for robotics learning, and no roadmap item needs gradients through the simulation.
- [ ] https://arxiv.org/abs/2106.13281 (Physics)
	**Brax: A Differentiable Physics Engine for Large Scale Rigid Body Simulation**: Brax is a JAX simulator for reinforcement learning on accelerators, which does not match S1's Jolt-based authoritative physics.
- [ ] https://ieeexplore.ieee.org/document/10589638 (Physics)
	**A Review of Differentiable Simulators**: a survey of simulators that compute gradients for robotics and learning, and S1's Jolt-based authoritative physics needs no gradients through the simulation.
- [ ] https://arxiv.org/abs/2312.03297 (Physics)
	**SoftMAC: Differentiable Soft Body Simulation with Forecast-based Contact Model and Two-way Coupling with Articulated Rigid Bodies and Clothes**: an MPM soft-body simulator made differentiable for robotic manipulation, which matches neither S1's rigid-body Jolt lane nor any roadmap need for gradients.
- [ ] https://arxiv.org/abs/2509.20917 (Physics)
	**Efficient Differentiable Contact Model with Long-range Influence**: a contact model shaped for well-behaved gradients in differentiable rigid-body control, while S1 delegates contact to Jolt and needs no gradients.
- [ ] https://gpuopen.com/download/lightweight_attention-based_indirect_illumination.pdf (Rendering)
	**Lightweight Attention-Based Indirect Illumination**: a 2.2M-parameter neural network that predicts indirect light from reflective shadow maps, and no R1-R3 rung has global illumination or neural inference in it.
- [ ] https://research.nvidia.com/labs/rtr/publication/bitterli2020spatiotemporal/ (Rendering)
	**Spatiotemporal Reservoir Resampling for Real-Time Ray Tracing with Dynamic Direct Lighting**: ReSTIR resamples light samples across space and time for ray-traced direct lighting from millions of lights, and no rendering rung (R1 to R3) includes ray tracing.
- [ ] https://arxiv.org/abs/2204.07137 (Physics)
	**Accelerated Policy Learning with Parallel Differentiable Simulation**: centered on reinforcement-learning policy training, outside the engine roadmap.
- [ ] https://la.disneyresearch.com/publication/doc-differentiable-optimal-control-for-retargeting-motions-onto-legged-robots/ (Physics)
	**DOC: Differentiable Optimal Control for Retargeting Motions onto Legged Robots**: robot-control and hardware retargeting, outside the engine roadmap.
- [ ] https://github.com/awesome-physics/awesome-neural-physics
	Bibliography, not a paper to ingest. Keep as a discovery link if useful.
- [ ] https://gpuopen.com/advanced-rendering-research/
	Research index, not a paper to ingest. Keep as a discovery link if useful.




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[false,null,false,false,false,false,null]}
```
%%