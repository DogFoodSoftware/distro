function standard_conveyor_install() {
    set_install_dir

    if [[ $test_path == $src ]]; then
      mkdir -p `dirname $INSTALL_DIR`
      ln -s $src $INSTALL_DIR
    else
      mkdir -p $INSTALL_DIR
      if [ -d $src ]; then
	  cp -a $src/* $INSTALL_DIR
      elif [ -f $src ]; then
	  file=`basename $src`
	  file=`echo $file | perl -pe 's/\w+-//'`
	  cp $src $INSTALL_DIR/$file
      else
	  echo "Could not determine source to install." >&2
	  exit 1
      fi
    fi

    make_runtime_link
}

function make_runtime_link() {
    set_install_dir

    if [ ! -d "$INSTALL_DIR" ] && [ ! -L "$INSTALL_DIR" ]; then
	echo "Did not find expected installation dir or link '$INSTALL_DIR'." >&2
	exit 1
    fi

    RUNTIME_LINK="${home}/.conveyor/runtime/${domain}/${bare_name}"
    rm -f "$RUNTIME_LINK"
    if [ ! -d `dirname $RUNTIME_LINK` ]; then
	mkdir -p `dirname $RUNTIME_LINK`
    fi
    ln -s $INSTALL_DIR $RUNTIME_LINK
}

function set_install_dir() {
    # Actually, 'set install dir and vars set.'
    for i in home domain bare_name; do
	if eval "test x\$$i == x''";
	then
	    echo "'$i' required to 'make_runtime_link'." >&2
	    exit 1
	fi
    done
    
    INSTALL_DIR="$out/conveyor/$domain/$bare_name";
}

# For now, we manually finagle the documentation database. In future, this
# will be done with something like:
#
# con POST /documentation/</organizations relative ID>[<optional sub dir>] action=mount
# con PUT /documentation/</organizations relative ID>[<optional sub dir>] '{ ... patch spec }'
function link_docs() {
    local SOURCE_DIR="$1"
    local TARGET_DIR="$2"

    pushd "$SOURCE_DIR"

    for i in `ls .`; do
        if [[ -d $i ]]; then
	    if [[ ! -d "$TARGET_DIR/$i" ]]; then
		mkdir "$TARGET_DIR/$i"
	    fi
	    link_docs "$SOURCE_DIR/$i" "$TARGET_DIR/$i"
	else
	    rm -f "$TARGET_DIR/$i"
	    ln -s "$SOURCE_DIR/$i" "$TARGET_DIR/$i"
	fi
    done

    popd
}
