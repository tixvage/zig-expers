import sys

def main():
	text = ""
	text += ("//DONT EDIT THIS FILE\n")
	text += ("const std = @import(\"std\");\n")
	name = "DEFAULT"
	print(sys.argv[1])
	with open((sys.argv[1] + ".hm"),'r') as file:
	    for line in file:
	    	words = line.split()
	    if words[0] == "IMPORT":
	    		text+=("const {} = @import(\"{}\");\n".format(words[1], words[2]))
	    	elif words[0] == "SCENE":
	    		name = words[1]
	    		text+=("const {}".format(words[1]))
	    		text+=("= struct{\n\tconst Self = @This();\n\tscene: hm.scene.Scene,\n\tallocator: *std.mem.Allocator,\n\tpub fn new(allocator: *std.mem.Allocator) !*Self {\n\t\tvar temp = try allocator.create(Self);\n\t\ttemp.allocator = allocator;\n\t\ttemp.scene = hm.scene.Scene.new(allocator, .{ create_entities, destroy });\n\t\treturn temp;\n\t}")
	    		text+=("\n\tpub fn create_entities(scene: *hm.scene.Scene) anyerror!void {\n")
	    	elif words[0] == "ENTITY":
	    		text+=("\t\tvar {} = try scene.add_entity(\"{}\");\n".format(words[1], words[1]))
	    	elif words[0] == "COMPONENT":
	    		text+=("\t\ttry {}.add_component({}, .{{{}}});".format(words[1], words[2], ", ".join(words[3:])))
				pass
	text+=("\n\t}\n")
	text+=("\n\tpub fn destroy(scene: *hm.scene.Scene) i32 {{\n\t\tconst self = @fieldParentPtr({}, \"scene\", scene);\n\t\tscene._destroy();\n\t\tself.allocator.destroy(self);\n\t\treturn 0;\n\t}}".format(name))
	text+=("\n};")
	f = open((sys.argv[1] + ".zig"), "w")
	f.write(text)
	print(text)
if __name__ == "__main__":
	main()