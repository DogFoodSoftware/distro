{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "1.0.0-alpha9";
  name = "conveyor-composer-${version}";

  src = fetchurl {
    url = "https://getcomposer.org/download/1.0.0-alpha9/composer.phar";
    name = "composer.phar";
    md5 = "05df355b5277c8c9012470e699fa5494";
  };

  phases = [ "installPhase" ];

  home = builtins.getEnv "HOME";

  installPhase = ''
    RUNTIME_LINK="$home/.conveyor/runtime/dogfoodsoftware.com/conveyor-composer"
    INSTALL_DIR=$out/conveyor-composer

    mkdir -p $INSTALL_DIR
    cp -a $src $INSTALL_DIR/composer.phar
    mkdir -p `dirname "$RUNTIME_LINK"`
    rm -f "$RUNTIME_LINK"
    ln -s "$INSTALL_DIR" "$RUNTIME_LINK"
  ''; 

  meta = {
    description = "Conveyor packaged Composer dependency management for PHP.";
    homepage = http://getcomposer.org/;
  };
}