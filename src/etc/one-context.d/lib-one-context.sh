
CONTEXT_DIR=/var/lib/one-context

# check if any variable matching $vars is changed
# usage: if context_changed "ETH*_ALIAS*" "PASSWORD*" ; then
function context_changed() {

	CHANGED_VARS=()
	DELETED_VARS=()

	for var in "$@" ; do
		for f in "$CONTEXT_DIR"/changed/$var ; do
			if [ -f "$f" ] ; then
				bf=$(basename "$f")
				CHANGED_VARS+=("$bf")
			fi
		done
		for f in "$CONTEXT_DIR"/deleted/$var ; do
			if [ -f "$f" ] ; then
				bf=$(basename "$f")
				DELETED_VARS+=("$bf")
			fi
		done
	done
	[ -n "${CHANGED_VARS[*]}${DELETED_VARS[*]}" ]
}


# When system is reconfigured, move the variables from new to current dir
# usage: context_done "ETH0_*" "PASSWORD*"
context_done(){
	for var in "$@" ; do
		for f in "$CONTEXT_DIR"/new/$var ; do
			[ -f "$f" ] && cp "$f" "$CONTEXT_DIR/current"
		done
	done
}

# When system is reconfigured, delete variables from current
# usage: context_done_delete "ETH0_*"
context_done_delete(){
	for var in "$@" ; do
		for f in "$CONTEXT_DIR"/current/$var ; do
			[ -f "$f" ] && rm -f "$f"
		done
	done
}

function boolTrue()
{
   case "${!1^^}" in
       1|Y|YES|TRUE|ON)
           return 0
           ;;
       *)
           return 1
   esac
}
