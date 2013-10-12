#https://developer.gnome.org/gtk2/stable/ButtonWidgets.html

#GtkButton — A widget that creates a signal when clicked on
#GtkCheckButton — Create widgets with a discrete toggle button
#GtkRadioButton — A choice from multiple check buttons
#GtkToggleButton — Create buttons which retain their state
#GtkLinkButton — Create buttons bound to a URL
#GtkScaleButton — A button which pops up a scale
#GtkVolumeButton — A button which pops up a volume control

# Introduced in Gtk3
#GtkMenuButton — A widget that shows a menu when clicked on
#GtkSwitch — A "light switch" style toggle
#GtkLockButton — A widget to unlock or lock privileged operations

type GtkButton <: GtkBin
    handle::Ptr{GtkObject}
    function GtkButton()
        gc_ref(new(ccall((:gtk_button_new,libgtk),Ptr{GtkObject},())))
    end
    function GtkButton(title::String)
        gc_ref(new(ccall((:gtk_button_new_with_mnemonic,libgtk),Ptr{GtkObject},
            (Ptr{Uint8},), bytestring(title))))
    end
end


type GtkCheckButton <: GtkBin
    handle::Ptr{GtkObject}
    function GtkCheckButton()
        gc_ref(new(ccall((:gtk_check_button_new,libgtk),Ptr{GtkObject},())))
    end
    function GtkCheckButton(title::String)
        gc_ref(new(ccall((:gtk_check_button_new_with_mnemonic,libgtk),Ptr{GtkObject},
            (Ptr{Uint8},), bytestring(title))))
    end
end

type GtkToggleButton <: GtkBin
    handle::Ptr{GtkObject}
    function GtkToggleButton()
        gc_ref(new(ccall((:gtk_toggle_button_new,libgtk),Ptr{GtkObject},())))
    end
    function GtkToggleButton(title::String)
        gc_ref(new(ccall((:gtk_toggle_button_new_with_mnemonic,libgtk),Ptr{GtkObject},
            (Ptr{Uint8},), bytestring(title))))
    end
end

if gtk_version == 3
type GtkSwitch <: GtkWidget
    handle::Ptr{GtkObject}
    function GtkSwitch()
        gc_ref(new(ccall((:gtk_switch_new,libgtk),Ptr{GtkObject},())))
    end
end
function GtkSwitch(active::Bool)
    b = GtkSwitch()
    ccall((:gtk_switch_set_active,libgtk),Void,(Ptr{GtkObject},Cint),b,active)
    b
end
else
const GtkSwitch = GtkToggleButton
end

type GtkRadioButton <: GtkBin
    handle::Ptr{GtkObject}
    GtkRadioButton(group::Ptr{Void}=C_NULL) =
        gc_ref(new(ccall((:gtk_radio_button_new,libgtk),Ptr{GtkObject},
            (Ptr{Void},),group)))
    GtkRadioButton(group::Ptr{Void},label::String) =
        gc_ref(new(ccall((:gtk_radio_button_new_with_mnemonic,libgtk),Ptr{GtkObject},
            (Ptr{Void},Ptr{Uint8}),group,bytestring(label))))
    GtkRadioButton(label::String) =
        gc_ref(new(ccall((:gtk_radio_button_new_with_mnemonic,libgtk),Ptr{GtkObject},
            (Ptr{Void},Ptr{Uint8}),C_NULL,bytestring(label))))
    GtkRadioButton(group::GtkRadioButton) =
        gc_ref(new(ccall((:gtk_radio_button_new_from_widget,libgtk),Ptr{GtkObject},
            (Ptr{GtkObject},),group)))
    GtkRadioButton(group::GtkRadioButton,label::String) =
        gc_ref(new(ccall((:gtk_radio_button_new_with_mnemonic_from_widget,libgtk),Ptr{GtkObject},
            (Ptr{GtkObject},Ptr{Uint8}),group,bytestring(label))))
end
GtkRadioButton(group::GtkRadioButton,child::GtkWidget,vargs...) =
    push!(GtkRadioButton(group,vargs...), child)

type GtkRadioButtonGroup <: GtkContainer
    # when iterating/indexing elements will be in reverse / *random* order

    # the behavior is specified as undefined if the first
    # element is moved to a new group
    # do not rely on the current behavior, since it may change
    handle::GtkContainer
    anchor::GtkRadioButton
    GtkRadioButtonGroup(layout::GtkContainer) = new(layout)
end
GtkRadioButtonGroup() = GtkRadioButtonGroup(GtkBox(true))
function GtkRadioButtonGroup(elem::Vector, active::Int=1)
    grp = GtkRadioButtonGroup()
    for (i,e) in enumerate(elem)
        push!(grp, e, i==active)
    end
    grp
end
convert(::Type{Ptr{GtkObject}},grp::GtkRadioButtonGroup) = convert(Ptr{GtkObject},grp.handle)
show(io::IO,::GtkRadioButtonGroup) = print(io,"GtkRadioButtonGroup()")
function push!(grp::GtkRadioButtonGroup,e::GtkRadioButton,active::Bool)
    push!(grp, e)
    gtk_toggle_button_set_active(e, active)
    grp
end
function push!(grp::GtkRadioButtonGroup,e::GtkRadioButton)
    if isdefined(grp,:anchor)
        e[:group] = grp.anchor
    else
        grp.anchor = e
    end
    push!(grp.handle, e)
    grp
end
function push!(grp::GtkRadioButtonGroup,label,active::Union(Bool,Nothing)=nothing)
    if isdefined(grp,:anchor)
        e = GtkRadioButton(grp.anchor, label)
    else
        grp.anchor = e = GtkRadioButton(label)
    end
    if isa(active,Bool)
        gtk_toggle_button_set_active(e,active::Bool)
    end
    push!(grp.handle, e)
    grp
end
function start(grp::GtkRadioButtonGroup)
    if isempty(grp)
        list = ()
    else
        list = gslist(ccall((:gtk_radio_button_get_group,libgtk), Ptr{GSList},
            (Ptr{GtkObject},), grp.anchor), false)
    end
    (list,list)
end
function next(w::GtkRadioButtonGroup,i)
    d,s = next(i[1],i[2])
    (convert(GtkWidget,convert(Ptr{GtkObject},d))::GtkRadioButton, (i[1],s))
end
done(w::GtkRadioButtonGroup,s::(GSList,GSList)) = false
done(w::GtkRadioButtonGroup,s::(Any,())) = true
length(w::GtkRadioButtonGroup) = length(start(w)[2])
getindex(w::GtkRadioButtonGroup, i::Integer) = convert(GtkWidget,convert(Ptr{GtkObject},start(w)[2][i]))::GtkRadioButton
isempty(grp::GtkRadioButtonGroup) = !isdefined(grp,:anchor)
function getindex(grp::GtkRadioButtonGroup,name::Union(Symbol,ByteString))
    k = symbol(name)
    if k == :active
        for b in grp
            if b[:active,Bool]
                return b
            end
        end
        error("no active elements in GtkRadioGroup")
    end
    error("GtkRadioButtonGroup has no property $name")
end


function gtk_toggle_button_set_active(b::GtkWidget, active::Bool)
    # Users are encouraged to use the syntax `b[:active] = true`. This is not a public function.
    ccall((:gtk_toggle_button_set_active,libgtk),Void,(Ptr{GtkObject},Cint),b,active)
    b
end
# Append a named argument, active::Bool, to the various constructors
# but first, resolve some conflicts
GtkRadioButton(a::GtkRadioButton,active::Bool) = gtk_toggle_button_set_active(GtkRadioButton(a),active)
GtkRadioButton(a::GtkRadioButton,b::GtkWidget,active::Bool) = gtk_toggle_button_set_active(GtkRadioButton(a,b),active)
GtkRadioButton(a::GtkRadioButton,b,active::Bool) = gtk_toggle_button_set_active(GtkRadioButton(a,b),active)
for btn in (:GtkCheckButton, :GtkToggleButton, :GtkRadioButton)
    @eval begin
        $btn(active::Bool) = gtk_toggle_button_set_active($btn(),active)
        $btn(a,active::Bool) = gtk_toggle_button_set_active($btn(a),active)
        $btn(a::GtkWidget,active::Bool) = gtk_toggle_button_set_active($btn(a),active)
        $btn(a,b,active::Bool) = gtk_toggle_button_set_active($btn(a,b),active)
        $btn(a,b,c,active::Bool) = gtk_toggle_button_set_active($btn(a,b,c),active)
    end
end


type GtkLinkButton <: GtkBin
    handle::Ptr{GtkObject}
    GtkLinkButton(uri::String) =
        gc_ref(new(ccall((:gtk_switch_new,libgtk),Ptr{GtkObject},
            (Ptr{Uint8},),bytestring(uri))))
    GtkLinkButton(uri::String,label::String) =
        gc_ref(new(ccall((:gtk_link_button_new_with_label,libgtk),Ptr{GtkObject},
            (Ptr{Uint8},Ptr{Uint8}),bytestring(uri),bytestring(label))))
end
function GtkLinkButton(uri::String,label::String,visited::Bool)
    b = GtkLinkButton(uri,label)
    ccall((:gtk_link_button_set_visited,libgtk),Void,(Ptr{GtkObject},Cint),b,visited)
    b
end
function GtkLinkButton(uri::String,visited::Bool)
    b = GtkLinkButton(uri)
    ccall((:gtk_link_button_set_visited,libgtk),Void,(Ptr{GtkObject},Cint),b,visited)
    b
end

#TODO: GtkScaleButton

type GtkVolumeButton <: GtkBin
    handle::Ptr{GtkObject}
    GtkLinkButton() =
        gc_ref(new(ccall((:gtk_volume_button_new,libgtk),Ptr{GtkObject},())))
end
function GtkVolumeButton(value::Real) # 0<=value<=1
    b = GtkVolumeButton()
    ccall((:gtk_scale_button_set_value,libgtk),Void,(Ptr{Uint8},Cdouble),b,value)
    b
end