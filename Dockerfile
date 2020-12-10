FROM rootproject/root:6.22.00-ubuntu20.04

USER root

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
wget ca-certificates python python-dev gfortran build-essential \
ghostscript nano vim libboost-all-dev rsync gnuplot
RUN wget --quiet -O- https://bootstrap.pypa.io/get-pip.py | python -
RUN pip install numpy scipy

ADD . /home/hep/
WORKDIR /home/hep

ENV MG_VERSION="MG5_aMC_v2_7_3"

RUN wget --quiet -O- https://launchpad.net/mg5amcnlo/2.0/2.7.x/+download/MG5_aMC_v2.7.3.tar.gz | tar xzf -
WORKDIR /home/hep/${MG_VERSION}

ENV ROOTSYS /usr/local
ENV PATH $PATH:$ROOTSYS/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$ROOTSYS/lib

# install tools
RUN echo "install lhapdf6" | /home/hep/${MG_VERSION}/bin/mg5_aMC
RUN echo "install maddm" | /home/hep/${MG_VERSION}/bin/mg5_aMC
RUN echo "install ExRootAnalysis" | /home/hep/${MG_VERSION}/bin/mg5_aMC
RUN echo "install Delphes" | /home/hep/${MG_VERSION}/bin/mg5_aMC
RUN echo "install mg5amc_py8_interface" | /home/hep/${MG_VERSION}/bin/mg5_aMC
RUN echo "install MadAnalysis5" | /home/hep/${MG_VERSION}/bin/mg5_aMC

# disable autoupdate
RUN rm /home/hep/${MG_VERSION}/input/.autoupdate

# install PDF
WORKDIR /home/hep/${MG_VERSION}/HEPTools/lhapdf6/share/LHAPDF
# Download few default PDFs
RUN wget --quiet -O- http://lhapdfsets.web.cern.ch/lhapdfsets/current/NNPDF23_lo_as_0130_qed.tar.gz | tar xzf -
RUN wget --quiet -O- http://lhapdfsets.web.cern.ch/lhapdfsets/current/NNPDF30_lo_as_0130.tar.gz | tar xzf -
RUN wget --quiet -O- http://lhapdfsets.web.cern.ch/lhapdfsets/current/NNPDF31_lo_as_0130.tar.gz | tar xzf -

# set up LHAPDF config executable
RUN echo "set lhapdf /home/hep/${MG_VERSION}/HEPTools/lhapdf6/bin/lhapdf-config" | /home/hep/${MG_VERSION}/bin/mg5_aMC

# install models
RUN chmod 777 /home/hep/${MG_VERSION}/models
RUN cp -r /home/hep/Models/* /home/hep/${MG_VERSION}/models/


WORKDIR /var/MG_outputs
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/home/hep/${MG_VERSION}/HEPTools/lib/
CMD /bin/bash

