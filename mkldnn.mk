# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

ifeq ($(USE_MKLDNN), 1)
	MKLDNN_SUBMODDIR = $(ROOTDIR)/3rdparty/mkldnn
	MKLDNN_BUILDDIR = $(MKLDNN_SUBMODDIR)/build
	#OMP_LIBFILE = /opt/intel/lib/intel64/libiomp5.so
	MKLDNN_LIBFILE = $(MKLDNNROOT)/lib/libmkldnn.a
else
	$(warning is not used)	
endif

.PHONY: mkldnn mkldnn_clean

mkldnn_build: $(MKLDNN_LIBFILE) $(MKLDNNROOT)/include/mkldnn.hpp 

$(MKLDNN_LIBFILE) $(MKLDNNROOT)/include/mkldnn.hpp: $(ROOTDIR)/mkldnn.mk
	mkdir -p $(MKLDNNROOT)
	#cd $(MKLDNN_SUBMODDIR) && rm -rf external && cd scripts && ./prepare_mkl.sh && cd .. && cp -a external/*/* $(MKLDNNROOT)/.
	cmake $(MKLDNN_SUBMODDIR) \
		-DCMAKE_INSTALL_PREFIX=$(MKLDNNROOT) \
		-B$(MKLDNN_BUILDDIR) \
		-DARCH_OPT_FLAGS="-march=core-avx2" \
		-DWITH_TEST=OFF \
		-DWITH_EXAMPLE=OFF \
		-DMKLDNN_LIBRARY_TYPE=STATIC \
		-DMKLROOT=/opt/intel/mkl \
		-DMKLDNN_USE_MKL=FULL:STATIC \
		-DMKLDNN_THREADING=OMP

	$(MAKE) -j6 -C $(MKLDNN_BUILDDIR) VERBOSE=1
	$(MAKE) -C $(MKLDNN_BUILDDIR) install
	mkdir -p $(MXNET_LIBDIR)
	#cp $(OMP_LIBFILE) $(MXNET_LIBDIR)
mkldnn_clean:
	$(RM) -r 3rdparty/mkldnn/build
	#$(RM) -r $(MKLDNNROOT)

ifeq ($(USE_MKLDNN), 1)
mkldnn: mkldnn_build
else
mkldnn:
endif
