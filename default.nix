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
    alias pymod="pip list" #show installed modules

    pyadd(){ # add package to requirements.txt so it will be commited
      if ! cat requirements.txt | grep $1 &>/dev/null;then
        echo $1 >> requirements.txt
        pip3 install -r requirements.txt
      fi
    }
    pyrm(){ #remove package from requirements.txt so it won't be commited
      cat requirements.txt | sed -i "/$1/d" requirements.txt
      pip uninstall $1 -y
    }
  '';
}
