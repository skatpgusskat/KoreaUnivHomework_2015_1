#pragma once
#include "Color.h"
namespace Namse
{
	class Vector
	{
	public:
		GLdouble m_X, m_Y, m_Z;

		Vector()
			: m_X(0), m_Y(0), m_Z(0), m_Color(0, 0, 0){}
		Vector(GLdouble _x, GLdouble _y, GLdouble _z)
			:m_X(_x), m_Y(_y), m_Z(_z) {	}

		Vector operator+ (const Vector& _vector) const;
		Vector operator- () const;
		Vector operator- (const Vector& _vector) const;
		Vector operator* (GLdouble _factor) const;
		Vector operator/ (GLdouble _factor) const;
		Vector& operator+= (const Vector& _vector);
		Vector& operator-= (const Vector& _vector);
		Vector& operator*= (GLdouble _factor);
		Vector& operator/= (GLdouble _factor);
		GLdouble DotProduct(const Vector& _vector) const;
		Vector Unit() const;
		GLdouble Norm() const;
		Vector CrossProduct(const Vector& _vector) const;


		

		virtual void MoveBy(Vector _vector);
		virtual void RotateBy(GLdouble _angleX, GLdouble _angleY, GLdouble _angleZ);

		Namse::Color m_Color;
	};

}