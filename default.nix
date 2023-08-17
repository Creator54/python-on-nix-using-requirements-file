with import <nixpkgs> { };
pkgs.mkShell rec {
  name = "impurePythonEnv";
  venvDir = "./.venv";
  buildInputs = [
    python310
  ];

  shellHook = ''
    set -h #remove "bash: hash: hashing disabled" warning !
    SOURCE_DATE_EPOCH=$(date +%s)

    if ! [ -d "${venvDir}" ]; then
      python -m venv "${venvDir}"
    fi
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [ zlib stdenv.cc.cc ]}":LD_LIBRARY_PATH;
    source "${venvDir}/bin/activate"
    python -m pip install --upgrade pip
    pip install -r requirements.txt
    eval "$extras"
  '';
  extras = ''
    pymod() {
    	pip list
    }

    pyadd() {
    	for pkg in "$@"; do
    		if ! grep -q "$pkg" requirements.txt; then
    			if pip install "$pkg"; then
    				echo "$pkg" >>requirements.txt
          fi
    		fi
    	done
    }

    pyrm() {
    	if [ $# -eq 0 ] && [ -e ./requirements.txt ] && [ -s ./requirements.txt ]; then
    		pkg=$(cat requirements.txt | fzf)
    		if [ -n "$pkg" ]; then
    			grep -v "$pkg" requirements.txt >requirements.tmp
    			mv requirements.tmp requirements.txt
    			pip uninstall "$pkg" -y
    		fi
    	else
    		for pkg in "$@"; do
    			grep -v "$pkg" requirements.txt >requirements.tmp
    			mv requirements.tmp requirements.txt
    			pip uninstall "$pkg" -y
    		done
    	fi
    }

    if [ -n "$IN_NIX_SHELL" ]; then
    	echo "Extra Functions:"
    	echo "pymod : Show a list of installed Python packages."
    	echo "pyadd : Add packages to requirements.txt and install them."
    	echo "pyrm  : Remove packages from requirements.txt and uninstall them."
    fi
  '';
}
