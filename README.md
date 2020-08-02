# A containerised platform for Geographic Data Science: `gds_env`

[![](https://images.microbadger.com/badges/image/darribas/gds:5.0.svg)](https://microbadger.com/images/darribas/gds:5.0 "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/darribas/gds:5.0.svg)](https://microbadger.com/images/darribas/gds:5.0 "Get your own version badge on microbadger.com")

* [Dani Arribas-Bel](http://darribas.org)
  [[`@darribas`](http://twitter.com/darribas)]
  
The `gds_env` (short for "GDS environment") provides a modern platform for Geographic Data Science. The project is a [Jupyter](https://jupyter.org/)-based stack that includes state-of-the-art **geospatial** libraries for **Python** and **R**. The `gds_env` is based on **container** technology to make it a transferrable platform for reproducibility. The source code is released under an [open source license](https://github.com/darribas/gds_env/blob/master/LICENSE) and the build process is transparent.

The `gds_env` extends the official [Jupyter Docker Stack](https://jupyter-docker-stacks.readthedocs.io/en/latest/) to include geospatial functionality in both Python and R. To offer more flexibility, this extension is provided in three different flavours, or stacks (to ): [`gds_py`](stacks/gds_py), [`gds`](stacks/gds) and [`gds_dev`](stacks/gds_dev). Each of them builds on each other and adds further functionality. Please check the [Stacks section](stacks) for more information.

The goal of the `gds_env` is to make using Python and R for geospatial easy to set up in a large variety of contexts. The `gds_env` can support research and teaching activities, but is also suitable for data scientists using Python and R "in the field". The stacks can be used in a range of environments, including: Windows/Mac/Linux laptops and desktops, servers, compute clusters, supercomputers or in the cloud (e.g. you can deploy them on [Binder](https://mybinder.org/)). For more information on how to build or install any of the stacks, check the [Guides section](guides).

## Building blocks

The `gds_env` stands on the shoulders of giants. Here are the core open technologies it is built with:

[<img src="https://upload.wikimedia.org/wikipedia/commons/c/c3/Python-logo-notext.svg" alt="Python" width="75" height="90">](https://www.python.org/)
[<img src="https://www.r-project.org/logo/Rlogo.svg" alt="R-project" width="75" height="90">](https://www.r-project.org/)
[<img src="https://upload.wikimedia.org/wikipedia/commons/3/38/Jupyter_logo.svg" alt="Jupyter" width="75" height="90">](https://jupyter.org/)
[<img src="https://www.docker.com/sites/default/files/d8/2019-07/vertical-logo-monochromatic.png" alt="Docker" width="75" height="90">](https://www.docker.com/)
[<img src="https://upload.wikimedia.org/wikipedia/commons/d/d5/Virtualbox_logo.png" alt="VirtualBox" width="75" height="90">](https://www.virtualbox.org/)

## Community

The `gds_env` is an open-source project. To join the conversation, please read through its [community guidelines](contributing).

## Citation

[![DOI](https://zenodo.org/badge/65582539.svg)](https://zenodo.org/badge/latestdoi/65582539)

```bibtex
@software{gds_env,
  author = { { Dani Arribas-Bel } },
  title = {\texttt{gds\_env}: A containerised platform for Geographic Data Science},
  url = {https://github.com/darribas/gds_env},
  version = {5.0},
  date = {2019-08-06},
}
```

## License

The code to generate the `gds_env` stacks is released under a BSD License. More details available on the repository's [license document](https://github.com/darribas/gds_env/blob/master/LICENSE).

---

[<img src="https://github.com/darribas/gds_env/raw/master/website/gdsl.png" width="250">](https://www.liverpool.ac.uk/geographic-data-science/)

