extends Node
class_name Math


static var delta:float
static func move_to(from,to,_delta:float):
	delta = _delta
	var type:=typeof(from)
	if type == TYPE_TRANSFORM3D:
		var p :Transform3D= get_difference(from,to)
		var o_dif :Vector3= (to).origin-from.origin
		var plen := o_dif.length()
		var a :float= min(plen,delta)
		var o:Vector3=o_dif.normalized()*a
		if delta == 0:
			o = Vector3.ZERO 
		var b:Basis = do_basis(delta,from.basis,to.basis)

		var t = add_transform(from,Transform3D(b,Vector3.ZERO))
		t.origin = from.origin + o
		return t
	elif type == TYPE_TRANSFORM2D:
		var p :Transform2D= get_difference(from,to)
		var o_dif :Vector2= to.origin- from.origin
		var o :Vector2= o_dif.normalized()*min(o_dif.length(),delta)
		if delta == 0:
			o = Vector2.ZERO
		var rot = limit_delta_rot(Quaternion(from.x,from.y,0,0),Quaternion(to.x,to.y,0,0),delta)
		var ret = Transform2D(Quaternion.IDENTITY.angle_to(rot), Vector2.ZERO)
		ret.origin = from.origin+o
		return ret
	elif type == TYPE_QUATERNION:
		var q = limit_delta_rot(from.normalized(),to.normalized(),delta)
		return add_transform(from,q)
	elif type == TYPE_BASIS:
		var t = do_basis(delta,from,to)
		return add_transform(from,t)
	elif type == TYPE_VECTOR4:
		var p:Vector4 = (to)-from
		if delta ==0:
			return from
		else:
			var t = min(p.length(),1.0)*p.normalized()*delta
			
			return from+t
	elif type == TYPE_VECTOR3:
		var p:Vector3 = (to)-from
		if delta <= 0:
			return from
		else:
			var t = min(p.length(),1.0)*p.normalized()*delta
			
			return from+t
	elif type == TYPE_VECTOR2:
		var p:Vector2 = (to)-from
		if delta == 0:
			return from
		else:
			var t = min(p.length(),1.0)*p.normalized()*delta
			
			return from+t
	elif type == TYPE_FLOAT:
		var p:float = (to)-from
		if delta == 0:
			return from
		else:
			var t = min(abs(p),abs(delta))*sign(p)*sign(delta)
			return from+t
static func limit_quaternion_rotation(from_quat:Quaternion,rot:Quaternion,mi: = 0,ma:=PI):
	rot = rot.normalized()
	var dest_quat = (rot*from_quat).normalized()
	ma = abs(ma)
	mi = abs(mi)
	if ma < mi:
		var temp = ma
		ma = mi
		mi = temp
	var to_identity = rot.get_angle()
	
	const ID = Quaternion.IDENTITY
	if  to_identity> ma:
		var weight = remap(ma,0.0,to_identity,0.0,1.0)
		rot = ID.slerp(rot,weight).normalized()
	to_identity = abs(rot.get_angle())
	if  to_identity< mi:
		var weight = remap(mi,0.0,to_identity,0.0,1.0)
		rot = ID.slerp(rot,weight).normalized()
	return rot.normalized()
static func get_difference(otf,dest):
	return dest*otf.inverse()
static func add_transform(otf,rot):
	return rot*otf
static func limit_delta_rot(otf,dest,_delta):
	delta = _delta
	var oquat = otf.normalized()
	var dquat = dest.normalized()
	var rot:Quaternion = get_difference(otf,dest).normalized()
	rot = Math.limit_quaternion_rotation(Quaternion.IDENTITY,rot,0.0,delta).normalized()
	if rot.is_equal_approx(Quaternion(0,0,0,0)):
		dest = Basis(oquat)
		return dest
	return Basis(rot).orthonormalized()
static func limit_rot(otf,dest,mi,ma):
	var oquat = otf.normalized()
	var dquat = dest.normalized()
	var rot:Quaternion = get_difference(otf,dest).normalized()
	rot = Math.limit_quaternion_rotation(oquat,rot,mi,ma)
	if rot.is_equal_approx(Quaternion(0,0,0,0)):
		dest = Basis(oquat)
		return dest
	dest =Basis(rot*oquat)
	return dest.orthonormalized()
static func do_basis(_delta,from,to):
	delta = _delta
	var from_quat = from.get_rotation_quaternion().normalized()
	var to_quat =to.get_rotation_quaternion().normalized()
	var rot=limit_delta_rot(from_quat,to_quat,delta)
	var tf = Basis(rot).orthonormalized()*scale_basis(delta,from,to)
	if (from.get_scale()-to.get_scale()).length() < 0.03:
		tf = tf.orthonormalized()
	return tf
static func scale_basis(_delta,from,to):
	delta = _delta
	var dest:Basis= (to)*Basis(to.orthonormalized().get_rotation_quaternion()).inverse()
	var old:Basis= (from)*Basis(from.orthonormalized().get_rotation_quaternion()).inverse()
	if delta == 0:
		return Basis.IDENTITY
	var target= dest.get_scale()-old.get_scale()
	var a = abs(delta)
	target.x *= min(a,abs(target.x))
	target.y *= min(a,abs(target.y))
	target.z *= min(a,abs(target.z))
	if target.x == -1.0:
		target.x *= 1.0+0.001
	if target.y == -1.0:
		target.y *= 1.0+0.001
	if target.z == -1.0:
		target.z *= 1.0+0.001
	target+= Vector3.ONE
		
	if (to.get_scale()-from.get_scale()).length()< delta:
		target = Vector3.ONE
	return Basis.IDENTITY.scaled(target)
static func get_axis(norm:Vector3,align_to:Basis):
	var up = norm
	var forw:Vector3= align_to.z
	if abs(align_to.z.dot(up)) == 1.0:
		forw = align_to.y*sign(up.dot(align_to.z))
	forw =forw.slide(up).slide(align_to.x).normalized()
	var result =Basis.looking_at(forw,up)
	var angle_diff = angle_difference(result.get_euler().y,align_to.get_euler().y)
	if abs(angle_diff )> PI*0.5:
		result = result.rotated(result.y,PI)
	return result
#from gnidel's badnik engine
static func seperate_plane(vec:Vector3,normal:Vector3)->Vector3:
	return project_plane(vec,normal)
static func combine_plane(plane_vec:Vector3,vec:Vector3,normal:Vector3)->Vector3:
	return project(vec,normal) + project_plane(plane_vec,normal)
static func seperate_projected(vec:Vector3,normal:Vector3)->Vector3:
	return project(vec,normal)
static func combine_projected(project_vec:Vector3,vec:Vector3,normal:Vector3)->Vector3:
	return project(project_vec,normal)+project_plane(vec,normal)
static func get_length(vector,normal):
	return vector.length() if normal.is_zero_approx() else signed_length(vector,normal)
static func clamp_length(vector:Vector3,mi:float,ma:float,normal:Vector3=Vector3.ZERO)->Vector3:
	var tmin = min(ma,mi)
	var tmax = max(ma,mi)
	var length = vector.length() if normal.is_zero_approx() else signed_length(vector,normal)
	if length < tmin:
		return vector.normalized()*abs(tmin)
	if length > tmax:
		return vector.normalized()*abs(tmax)
	return vector
static func project_plane(vector:Vector3,normal:Vector3)->Vector3:
	return vector - project(vector,normal)
static func signed_length(vector:Vector3,normal:Vector3):
	var projected = project(vector, normal);
	return projected.length() if (vector.normalized().dot(normal.normalized()) >= 0) else -projected.length()
static func project(vector:Vector3, normal:Vector3):
	return (vector.dot(normal) / normal.length_squared()) * normal
#static func rotate_q(q:Quaternion,o:Quaternion,t):
	#if q.get_angle() <= remap(target_dist,0.0,1.0,0,PI) or remap(delta,0.0,1.0,0,PI) <= 0:
		#return Quaternion.IDENTITY
	#var b = remap(abs(q.angle_to(Quaternion.IDENTITY)),0.0,PI,0.0,1.0)
	#var a :float = min(1.0,(delta)/b)
	#var o2 = o
	#o = o.slerp(t,a)
	#var c = (o2.inverse()*o).normalized().get_angle()
	#return  (o2.inverse()*o).normalized()
