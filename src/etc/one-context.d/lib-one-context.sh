
CONTEXT_DIR=/var/lib/one-context

# check if any variable matching $vars is changed
# usage: if context_changed "ETH*_ALIAS*" "PASSWORD*" ; then
function context_changed() {

	CHANGED_VARS=()
	DELETED_VARS=()

	for var in "$@" ; do
		for f in "$CONTEXT_DIR"/changed/$var ; do
			if [ -f "$f" ] ; then
				CHANGED_VARS+=("$var")
			fi
		done
		for f in "$CONTEXT_DIR"/deleted/$var ; do
			if [ -f "$f" ] ; then
				DELETD_VARS+=("$var")
			fi
		done
	done
	return [ -n "${CHANGED_VARS[*]}${DELETED_VARS[*]}" ]
}

