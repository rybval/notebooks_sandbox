FROM jupyter/scipy-notebook

EXPOSE 8888

USER root

# Install some useful Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt && \
  rm /tmp/requirements.txt

# Install additional kernels
RUN apt-get update
# gophernotes
ENV GOPATH=/home/jovyan/go
RUN apt-get install -y golang-go libzmq3-dev pkg-config && \
  go get -u github.com/gopherdata/gophernotes && \
  mkdir -p ~/.local/share/jupyter/kernels/gophernotes
RUN mkdir -p /usr/local/share/jupyter/kernels/gophernotes && \
  cp $GOPATH/src/github.com/gopherdata/gophernotes/kernel/* /usr/local/share/jupyter/kernels/gophernotes
# Bash
RUN pip install bash_kernel && \
  python -m bash_kernel.install
# C
RUN apt-get install -y gcc && \
  pip install jupyter-c-kernel && \
  install_c_kernel
# Java, Kotlin, etc.
RUN apt-get install -y default-jre
RUN conda install -y -q -c conda-forge ipywidgets beakerx
# C++
RUN conda install -y -q -c QuantStack -c conda-forge xeus-cling
# IJavascript
RUN conda install -y -q nodejs && \
  npm install -g --unsafe-perm ijavascript && \
  ijsinstall --install=global --spec-path=full

RUN fix-permissions /home/$NB_USER

USER $NB_UID

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0"]
