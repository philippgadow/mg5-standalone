FROM rootproject/root:6.28.00-ubuntu22.04

USER root

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
wget ca-certificates gfortran build-essential \
ghostscript nano vim libboost-all-dev rsync gnuplot
RUN wget --quiet -O- https://bootstrap.pypa.io/get-pip.py | python3 -
RUN pip3 install numpy scipy pandas matplotlib seaborn atlas-mpl-style

WORKDIR /home/hep

ENV MG_VERSION="MG5_aMC_v3_5_0"

RUN wget --quiet -O- https://launchpad.net/mg5amcnlo/3.0/3.5.x/+download/MG5_aMC_v3.5.0.tar.gz | tar xzf -
WORKDIR /home/hep/${MG_VERSION}

ENV ROOTSYS /usr/local
ENV PATH $PATH:$ROOTSYS/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$ROOTSYS/lib

# install tools
RUN echo "install lhapdf6" | /home/hep/${MG_VERSION}/bin/mg5_aMC
RUN echo "install mg5amc_py8_interface" | /home/hep/${MG_VERSION}/bin/mg5_aMC
RUN echo "install ExRootAnalysis" | /home/hep/${MG_VERSION}/bin/mg5_aMC

# disable autoupdate
RUN rm /home/hep/${MG_VERSION}/input/.autoupdate

# install PDF
WORKDIR /home/hep/${MG_VERSION}/HEPTools/lhapdf6_py3/share/LHAPDF
# Download few default PDFs
RUN wget --quiet -O- http://lhapdfsets.web.cern.ch/lhapdfsets/current/NNPDF23_lo_as_0130_qed.tar.gz | tar xzf -
RUN wget --quiet -O- http://lhapdfsets.web.cern.ch/lhapdfsets/current/NNPDF30_lo_as_0130.tar.gz | tar xzf -
RUN wget --quiet -O- http://lhapdfsets.web.cern.ch/lhapdfsets/current/NNPDF31_lo_as_0130.tar.gz | tar xzf -

# install Delphes
WORKDIR /home/hep/${MG_VERSION}/HEPTools
RUN wget --quiet -O- wget http://cp3.irmp.ucl.ac.be/downloads/Delphes-3.5.0.tar.gz | tar xzf - && cd Delphes-3.5.0 && make
ENV LD_LIBRARY_PATH /home/hep/${MG_VERSION}/HEPTools/Delphes-3.5.0/:$LD_LIBRARY_PATH
ENV ROOT_INCLUDE_PATH /home/hep/${MG_VERSION}/HEPTools/Delphes-3.5.0/external/:$ROOT_INCLUDE_PATH

# install Fastjet
RUN wget --quiet -O- http://fastjet.fr/repo/fastjet-3.3.4.tar.gz | tar xzf - && cd fastjet-3.3.4/ && ./configure --prefix=$PWD/build && make && make check && make install
ENV LD_LIBRARY_PATH /home/hep/${MG_VERSION}/HEPTools/fastjet-3.3.4/build/lib/:$LD_LIBRARY_PATH

# set up config executables
RUN echo "set lhapdf /home/hep/${MG_VERSION}/HEPTools/lhapdf6_py3/bin/lhapdf-config" | /home/hep/${MG_VERSION}/bin/mg5_aMC
RUN echo "set delphes_path /home/hep/${MG_VERSION}/HEPTools/Delphes-3.5.0/" | /home/hep/${MG_VERSION}/bin/mg5_aMC

# set up MadGraph
RUN echo "set auto_convert_model True" | /home/hep/${MG_VERSION}/bin/mg5_aMC
RUN ln /home/hep/${MG_VERSION}/bin/mg5_aMC /usr/bin/mg5_aMC

# install models
COPY . /home/hep/
RUN chmod 777 /home/hep/${MG_VERSION}/models
RUN cp -r /home/hep/Models/* /home/hep/${MG_VERSION}/models/

# set workdir and environment variables
WORKDIR /var/MG_outputs
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/home/hep/${MG_VERSION}/HEPTools/lib/
CMD /bin/bash
