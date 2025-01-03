module fem


    implicit none



    public
    double precision, dimension(:,:), allocatable :: point
    integer, dimension(:,:), allocatable :: ele
    double precision, dimension(1:20) :: phi_p3
    double precision, dimension(1:3,1:20) :: phi_p3_del
    double precision, dimension(1:3,1:3) :: J0,Jit
    double precision :: Jdet
    double precision, dimension(1:4,1:4) :: p1_matrix
    double precision, dimension(1:10,1:10) :: p2_matrix
    double precision, dimension(1:20,1:20) :: p3_matrix
    double precision, dimension(1:11,1:3) :: gpoint
    double precision, dimension(1:11) :: gweight



contains

subroutine jacobian(e1,e2,e3,e4)

    !! for LAPACK  
    integer :: info,n,e1,e2,e3,e4!,lwork
    double precision,dimension(:),allocatable :: work, ipiv


    ! allocate(J(1:3,1:3))

    J0(1,1) = point(e2,1)-point(e1,1)
    J0(1,2) = point(e3,1)-point(e1,1)
    J0(1,3) = point(e4,1)-point(e1,1)
    J0(2,1) = point(e2,2)-point(e1,2)
    J0(2,2) = point(e3,2)-point(e1,2)
    J0(2,3) = point(e4,2)-point(e1,2)
    J0(3,1) = point(e2,3)-point(e1,3)
    J0(3,2) = point(e3,3)-point(e1,3)
    J0(3,3) = point(e4,3)-point(e1,3)

    Jdet=J0(1,1)*(J0(2,2)*J0(3,3)-J0(2,3)*J0(3,2))&
             -J0(1,2)*(J0(2,1)*J0(3,3)-J0(2,3)*J0(3,1))&
             +J0(1,3)*(J0(2,1)*J0(3,2)-J0(2,2)*J0(3,1))

    allocate(work(3))
    allocate(ipiv(3))
    ! allocate(Jit(1:3,1:3))
    Jit = J0
    n = 3

    call DGETRF(n, n, Jit, n, ipiv, info)
    call DGETRI(n, Jit, n, ipiv, work, n, info)
    
    Jit = transpose(Jit)

    

end subroutine jacobian

function basis_p1(list) result(phi_p1)

    double precision,dimension(1:3) :: list

    double precision,dimension(1:4) :: phi_p1

    phi_p1(1)=1.0d0-list(1)-list(2)-list(3)
    phi_p1(2)=list(1)
    phi_p1(3)=list(2)
    phi_p1(4)=list(3)


end function basis_p1

function basis_p1_del(list) result(phi_p1_del)
    double precision, dimension(1:3) :: list

    double precision,dimension(1:4,1:3) :: phi_p1_del

    phi_p1_del(1,:)=(/-1.0d0,-1.0d0,-1.0d0/)
    phi_p1_del(2,:)=(/1.0d0,0.0d0,0.0d0/)
    phi_p1_del(3,:)=(/0.0d0,1.0d0,0.0d0/)
    phi_p1_del(4,:)=(/0.0d0,0.0d0,1.0d0/)

end function basis_p1_del



function basis_p2(list) result(phi_p2)

    double precision,dimension(1:3) :: list
    double precision,dimension(1:10) :: phi_p2
    
    phi_p2(1) =(1.0d0-list(1)-list(2)-list(3))*(1.0d0-2.0d0*list(1)-2.0d0*list(2)-2.0d0*list(3))
    phi_p2(2) =2.0d0*list(1)*(list(1)-0.5d0)
    phi_p2(3) =2.0d0*list(2)*(list(2)-0.5d0)
    phi_p2(4) =2.0d0*list(3)*(list(3)-0.5d0)
    phi_p2(5) =4.0d0*list(1)*(1.0d0-list(1)-list(2)-list(3))
    phi_p2(6) =4.0d0*list(1)*list(2)
    phi_p2(7) =4.0d0*list(2)*(1.0d0-list(1)-list(2)-list(3))
    phi_p2(8) =4.0d0*list(3)*(1.0d0-list(1)-list(2)-list(3))
    phi_p2(9) =4.0d0*list(1)*list(3)
    phi_p2(10)=4.0d0*list(2)*list(3)

end function basis_p2

function basis_p2_del(list) result(phi_p2_del)

    double precision,dimension(1:3) :: list
    double precision,dimension(1:10,1:3) :: phi_p2_del

    phi_p2_del(1,1:3) =(/-3.0d0+4.0d0*list(1)+4.0d0*list(2)+4.0d0*list(3),-3.0d0+4.0d0*list(1)+4.0d0*list(2)+4.0d0*list(3),&
                         -3.0d0+4.0d0*list(1)+4.0d0*list(2)+4.0d0*list(3)/)
    phi_p2_del(2,1:3) =(/4.0d0*list(1)-1.0d0,0.0d0,0.0d0/)
    phi_p2_del(3,1:3) =(/0.0d0,4.0d0*list(2)-1.0d0,0.0d0/)
    phi_p2_del(4,1:3) =(/0.0d0,0.0d0,4.0d0*list(3)-1.0d0/)
    phi_p2_del(5,1:3) =(/4.0d0*(1.0d0-2.0d0*list(1)-list(2)-list(3)),-4.0d0*list(1),-4.0d0*list(1)/)
    phi_p2_del(6,1:3) =(/4.0d0*list(2),4.0d0*list(1),0.0d0/)
    phi_p2_del(7,1:3) =(/-4.0d0*list(2),4.0d0*(1.0d0-list(1)-2.0d0*list(2)-list(3)),-4.0d0*list(2)/)
    phi_p2_del(8,1:3) =(/-4.0d0*list(3),-4.0d0*list(3),4.0d0*(1.0d0-list(1)-list(2)-2.0d0*list(3))/)
    phi_p2_del(9,1:3) =(/4.0d0*list(3),0.0d0,4.0d0*list(1)/)
    phi_p2_del(10,1:3)=(/0.0d0,4.0d0*list(3),4.0d0*list(2)/)
    
end function basis_p2_del




function basis_p3(list) result(phi_p3)

    double precision,dimension(1:3) :: list
    double precision,dimension(1:20) :: phi_p3
    
phi_p3(1) =9.0d0/2.0d0*(1.0d0-list(1)-list(2)-list(3))*(2.0d0/3.0d0-list(1)-list(2)-list(3))*(1.0d0/3.0d0-list(1)-list(2)-list(3))
phi_p3(2) =9.0d0/2.0d0*list(1)*(list(1)-1.0d0/3.0d0)*(list(1)-2.0d0/3.0d0)
phi_p3(3) =9.0d0/2.0d0*list(2)*(list(2)-1.0d0/3.0d0)*(list(2)-2.0d0/3.0d0)
phi_p3(4) =9.0d0/2.0d0*list(3)*(list(3)-1.0d0/3.0d0)*(list(3)-2.0d0/3.0d0)
phi_p3(5) =27.0d0/2.0d0*list(1)*(1.0d0-list(1)-list(2)-list(3))*(2.0d0/3.0d0-list(1)-list(2)-list(3))
phi_p3(6) =27.0d0/2.0d0*list(1)*(1.0d0-list(1)-list(2)-list(3))*(list(1)-1.0d0/3.0d0)
phi_p3(7) =27.0d0/2.0d0*list(1)*(list(1)-1.0d0/3.0d0)*list(2)
phi_p3(8) =27.0d0/2.0d0*list(1)*list(2)*(list(2)-1.0d0/3.0d0)
phi_p3(9) =27.0d0/2.0d0*list(2)*(1.0d0-list(1)-list(2)-list(3))*(list(2)-1.0d0/3.0d0)
phi_p3(10)=27.0d0/2.0d0*list(2)*(1.0d0-list(1)-list(2)-list(3))*(2.0d0/3.0d0-list(1)-list(2)-list(3))
phi_p3(11)=27.0d0/2.0d0*list(3)*(1.0d0-list(1)-list(2)-list(3))*(2.0d0/3.0d0-list(1)-list(2)-list(3)) 
phi_p3(12)=27.0d0/2.0d0*list(3)*(1.0d0-list(1)-list(2)-list(3))*(list(3)-1.0d0/3.0d0) 
phi_p3(13)=27.0d0/2.0d0*list(1)*list(3)*(list(1)-1.0d0/3.0d0) 
phi_p3(14)=27.0d0/2.0d0*list(1)*list(3)*(list(3)-1.0d0/3.0d0)  
phi_p3(15)=27.0d0/2.0d0*list(2)*list(3)*(list(2)-1.0d0/3.0d0)  
phi_p3(16)=27.0d0/2.0d0*list(2)*list(3)*(list(3)-1.0d0/3.0d0)  
phi_p3(17)=27.0d0*list(1)*list(2)*list(3) 
phi_p3(18)=27.0d0*list(2)*list(3)*(1.0d0-list(1)-list(2)-list(3))  
phi_p3(19)=27.0d0*list(1)*list(3)*(1.0d0-list(1)-list(2)-list(3))  
phi_p3(20)=27.0d0*list(1)*list(2)*(1.0d0-list(1)-list(2)-list(3)) 

end function basis_p3



function basis_p3_del(list) result(phi_p3_del)

    double precision,dimension(1:3) :: list
    double precision,dimension(1:20,1:3) :: phi_p3_del

phi_p3_del(1,1:3) =(/-(9.0d0*(list(1)+list(2)+list(3))*(3.0d0*(list(1)+list(2)+list(3))-4.0d0)+11.0d0)/2.0d0,&
                  -(9.0d0*(list(1)+list(2)+list(3))*(3.0d0*(list(1)+list(2)+list(3))-4.0d0)+11.0d0)/2.0d0,&
                  -(9.0d0*(list(1)+list(2)+list(3))*(3.0d0*(list(1)+list(2)+list(3))-4.0d0)+11.0d0)/2.0d0/)

phi_p3_del(2,1:3) =(/(27.0d0*list(1)**2-18.0d0*list(1)+2.0d0)/2.0d0,0.0d0,0.0d0/)
phi_p3_del(3,1:3) =(/0.0d0,(27.0d0*list(2)**2-18.0d0*list(2)+2.0d0)/2.0d0,0.0d0/)
phi_p3_del(4,1:3) =(/0.0d0,0.0d0,(27.0d0*list(3)**2-18.0d0*list(3)+2.0d0)/2.0d0/)

phi_p3_del(5,1:3) =(/(81.0d0*list(1)**2+(108.0d0*list(2)+108.0d0*list(3)-90.0d0)*list(1)+27.0d0*list(2)**2+27.0d0*list(3)**2+&
54.0d0*list(2)*list(3)-45.0d0*list(2)-45.0d0*list(3)+18.0d0)/2.0d0,1.0d0/2.0d0*9.0d0*list(1)*(6.0d0*(list(1)+list(2)+list(3))-&
5.0d0),1.0d0/2.0d0*9.0d0*list(1)*(6.0d0*(list(1)+list(2)+list(3))-5.0d0)/)

phi_p3_del(6,1:3) =(/-9.0d0/2.0d0*(9.0d0*list(1)**2+(6.0d0*list(2)+6.0d0*list(3)-8.0d0)*list(1)-list(2)-list(3)+1.0d0),-27.0d0/&
2.0d0*list(1)*(list(1)-1.0d0/3.0d0),-27.0d0/2.0d0*list(1)*(list(1)-1.0d0/3.0d0)/)

phi_p3_del(7,1:3) =(/(6.0d0*list(1)-1.0d0)*9.0d0*list(2)/2.0d0,27.0d0/2.0d0*list(1)*(list(1)-1.0d0/3.0d0),0.0d0/)
phi_p3_del(8,1:3) =(/27.0d0/2.0d0*list(2)*(list(2)-1.0d0/3.0d0),(6.0d0*list(2)-1.0d0)*9.0d0*list(1)/2.0d0,0.0d0/)

phi_p3_del(9,1:3) =(/-27.0d0/2.0d0*list(2)*(list(2)-1.0d0/3.0d0),-9.0d0/2.0d0*(9.0d0*list(2)**2+(6.0d0*list(1)+6.0d0*list(3)-&
8.0d0)*list(2)-list(1)-list(3)+1.0d0),-27.0d0/2.0d0*list(2)*(list(2)-1.0d0/3.0d0)/)

phi_p3_del(10,1:3)=(/1.0d0/2.0d0*9.0d0*list(2)*(6.0d0*(list(1)+list(2)+list(3))-5.0d0),(81.0d0*list(2)**2+(108.0d0*list(1)+&
108.0d0*list(3)-90.0d0)*list(2)+27.0d0*list(1)**2+27.0d0*list(3)**2+54.0d0*list(1)*list(3)-45.0d0*list(1)-45.0d0*list(3)+18.0d0)&
/2.0d0,1.0d0/2.0d0*9.0d0*list(2)*(6.0d0*(list(1)+list(2)+list(3))-5.0d0)/)

phi_p3_del(11,1:3)=(/1.0d0/2.0d0*9.0d0*list(3)*(6.0d0*(list(1)+list(2)+list(3))-5.0d0),1.0d0/2.0d0*9.0d0*list(3)*(6.0d0*(list(1)&
+list(2)+list(3))-5.0d0),(81.0d0*list(3)**2+(108.0d0*list(2)+108.0d0*list(1)-90.0d0)*list(3)+27.0d0*list(2)**2+27.0d0*list(1)**2+&
54.0d0*list(2)*list(1)-45.0d0*list(2)-45.0d0*list(1)+18.0d0)/2.0d0/)

phi_p3_del(12,1:3)=(/-27.0d0/2.0d0*list(3)*(list(3)-1.0d0/3.0d0),-27.0d0/2.0d0*list(3)*(list(3)-1.0d0/3.0d0),-9.0d0/2.0d0*(9.0d0&
*list(3)**2+(6.0d0*list(2)+6.0d0*list(1)-8.0d0)*list(3)-list(2)-list(1)+1.0d0)/)

phi_p3_del(13,1:3)=(/(6.0d0*list(1)-1.0d0)*9.0d0*list(3)/2.0d0,0.0d0,27.0d0/2.0d0*list(1)*(list(1)-1.0d0/3.0d0)/)
phi_p3_del(14,1:3)=(/27.0d0/2.0d0*list(3)*(list(3)-1.0d0/3.0d0),0.0d0,(6.0d0*list(3)-1.0d0)*9.0d0*list(1)/2.0d0/)
phi_p3_del(15,1:3)=(/0.0d0,(6.0d0*list(2)-1.0d0)*9.0d0*list(3)/2.0d0,27.0d0/2.0d0*list(2)*(list(2)-1.0d0/3.0d0)/)
phi_p3_del(16,1:3)=(/0.0d0,27.0d0/2.0d0*list(3)*(list(3)-1.0d0/3.0d0),(6.0d0*list(3)-1.0d0)*9.0d0*list(2)/2.0d0/)
phi_p3_del(17,1:3)=(/27.0d0*list(2)*list(3),27.0d0*list(1)*list(3),27.0d0*list(1)*list(2)/)

phi_p3_del(18,1:3)=(/-27.0d0*list(2)*list(3),27.0d0*list(3)*((1.0d0-list(1)-list(2)-list(3))-list(2)),&
27.0d0*list(2)*((1.0d0-list(1)-list(2)-list(3))-list(3))/)

phi_p3_del(19,1:3)=(/27.0d0*list(3)*((1.0d0-list(1)-list(2)-list(3))-list(1)),-27.0d0*list(1)*list(3),&
27.0d0*list(1)*((1.0d0-list(1)-list(2)-list(3))-list(3))/)

phi_p3_del(20,1:3)=(/27.0d0*list(2)*((1.0d0-list(1)-list(2)-list(3))-list(1)),27.0d0*list(1)*((1.0d0-&
list(1)-list(2)-list(3))-list(2)),-27.0d0*list(1)*list(2)/)
    
end function basis_p3_del










    subroutine mass_mat()
   

        p1_matrix(1,:) =  (/1.0d0/60.0d0,1.0d0/120.0d0,1.0d0/120.0d0,1.0d0/120.0d0/)
        p1_matrix(2,:) =  (/1.0d0/120.0d0,1.0d0/60.0d0,1.0d0/120.0d0,1.0d0/120.0d0/)
        p1_matrix(3,:) =  (/1.0d0/120.0d0,1.0d0/120,1.0d0/60.0d0,1.0d0/120.0d0/)
        p1_matrix(4,:) =  (/1.0d0/120.0d0,1.0d0/120,1.0d0/120.0d0,1/60.0d0/)
    
    
        p2_matrix(1,:)  =  (/1.0d0/420.0d0,1.0d0/2520.0d0,1.0d0/2520.0d0,1.0d0/2520.0d0,-1.0d0/630.0d0,-1.0d0/420.0d0,&
                                 -1.0d0/630.0d0,-1.0d0/630.0d0,-1.0d0/420.0d0,-1.0d0/420.0d0/)
        p2_matrix(2,:)  =  (/1.0d0/2520.0d0,1.0d0/420.0d0,1.0d0/2520.0d0,1.0d0/2520.0d0,-1.0d0/630.0d0,-1.0d0/630.0d0,&
                                 -1.0d0/420.0d0,-1.0d0/420.0d0,-1.0d0/630.0d0,-1.0d0/420.0d0/)
        p2_matrix(3,:)  =  (/1.0d0/2520.0d0,1.0d0/2520.0d0,1.0d0/420.0d0,1.0d0/2520.0d0,-1.0d0/420.0d0,-1.0d0/630.0d0,&
                                 -1.0d0/630.0d0,-1.0d0/420.0d0,-1.0d0/420.0d0,-1.0d0/630.0d0/)
        p2_matrix(4,:)  =  (/1.0d0/2520.0d0,1.0d0/2520.0d0,1.0d0/2520.0d0,1.0d0/420.0d0,-1.0d0/420.0d0,-1.0d0/420.0d0,&
                                 -1.0d0/420.0d0,-1.0d0/630.0d0,-1.0d0/630.0d0,-1.0d0/630.0d0/)
        p2_matrix(5,:)  =  (/-1.0d0/630.0d0,-1.0d0/630.0d0,-1.0d0/420.0d0,-1.0d0/420.0d0,4.0d0/315.0d0,2.0d0/315.0d0,&
                                   2.0d0/315.0d0,2.0d0/315.0d0,2.0d0/315.0d0,1.0d0/315.0d0/)
        p2_matrix(6,:)  =  (/-1.0d0/420.0d0,-1.0d0/630.0d0,-1.0d0/630.0d0,-1.0d0/420.0d0,2.0d0/315.0d0,4.0d0/315.0d0,&
                                   2.0d0/315.0d0,1.0d0/315.0d0,2.0d0/315.0d0,2.0d0/315.0d0/)
        p2_matrix(7,:)  =  (/-1.0d0/630.0d0,-1.0d0/420.0d0,-1.0d0/630.0d0,-1.0d0/420.0d0,2.0d0/315.0d0,2.0d0/315.0d0,&
                                   4.0d0/315.0d0,2.0d0/315.0d0,1.0d0/315.0d0,2.0d0/315.0d0/)
        p2_matrix(8,:)  =  (/-1.0d0/630.0d0,-1.0d0/420.0d0,-1.0d0/420.0d0,-1.0d0/630.0d0,2.0d0/315.0d0,1.0d0/315.0d0,&
                                   2.0d0/315.0d0,4.0d0/315.0d0,2.0d0/315.0d0,2.0d0/315.0d0/)
        p2_matrix(9,:)  =  (/-1.0d0/420.0d0,-1.0d0/630.0d0,-1.0d0/420.0d0,-1.0d0/630.0d0,2.0d0/315.0d0,2.0d0/315.0d0,&
                                   1.0d0/315.0d0,2.0d0/315.0d0,4.0d0/315.0d0,2.0d0/315.0d0/)
        p2_matrix(10,:) =  (/-1.0d0/420.0d0,-1.0d0/420.0d0,-1.0d0/630.0d0,-1.0d0/630.0d0,1.0d0/315.0d0,2.0d0/315.0d0,&
                                   2.0d0/315.0d0,2.0d0/315.0d0,2.0d0/315.0d0,4.0d0/315.0d0/)


p3_matrix(1,:) =(/ 1.0d0/1680.0d0,  1.0d0/13440.0d0, 1.0d0/13440.0d0, 1.0d0/13440.0d0, -1.0d0/2240.0d0,  1.0d0/4480.0d0,&
 1.0d0/8960.0d0,   1.0d0/8960.0d0,  1.0d0/4480.0d0, -1.0d0/2240.0d0, -1.0d0/2240.0d0,  1.0d0/4480.0d0,  1.0d0/8960.0d0, &
  1.0d0/8960.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0,  3.0d0/2240.0d0,  3.0d0/4480.0d0,  3.0d0/4480.0d0,  3.0d0/4480.0d0 /)
p3_matrix(2,:) =(/ 1.0d0/13440.0d0, 1.0d0/1680.0d0,  1.0d0/13440.0d0, 1.0d0/13440.0d0,  1.0d0/4480.0d0, -1.0d0/2240.0d0,&
-1.0d0/2240.0d0,   1.0d0/4480.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0, -1.0d0/2240.0d0, &
  1.0d0/4480.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0,  3.0d0/4480.0d0,  3.0d0/2240.0d0,  3.0d0/4480.0d0,  3.0d0/4480.0d0 /)
p3_matrix(3,:) =(/ 1.0d0/13440.0d0, 1.0d0/13440.0d0, 1.0d0/1680.0d0,  1.0d0/13440.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0,&
 1.0d0/4480.0d0,  -1.0d0/2240.0d0, -1.0d0/2240.0d0,  1.0d0/4480.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0, &
  1.0d0/8960.0d0, -1.0d0/2240.0d0,  1.0d0/4480.0d0,  3.0d0/4480.0d0,  3.0d0/4480.0d0,  3.0d0/2240.0d0,  3.0d0/4480.0d0 /)
p3_matrix(4,:) =(/ 1.0d0/13440.0d0, 1.0d0/13440.0d0, 1.0d0/13440.0d0, 1.0d0/1680.0d0,   1.0d0/8960.0d0,  1.0d0/8960.0d0,&
 1.0d0/8960.0d0,   1.0d0/8960.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0,  1.0d0/4480.0d0, -1.0d0/2240.0d0,  1.0d0/4480.0d0, &
 -1.0d0/2240.0d0,  1.0d0/4480.0d0, -1.0d0/2240.0d0,  3.0d0/4480.0d0,  3.0d0/4480.0d0,  3.0d0/4480.0d0,  3.0d0/2240.0d0 /)
p3_matrix(5,:) =(/-1.0d0/2240.0d0,  1.0d0/4480.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0,   9.0d0/2240.0d0, -9.0d0/4480.0d0,&
-9.0d0/8960.0d0,   0.0d0,          -9.0d0/8960.0d0,  9.0d0/4480.0d0,  9.0d0/4480.0d0, -9.0d0/8960.0d0, -9.0d0/8960.0d0, &
  0.0d0,           0.0d0,           0.0d0,          -9.0d0/4480.0d0,  0.0d0,           0.0d0,           0.0d0          /)
p3_matrix(6,:) =(/ 1.0d0/4480.0d0, -1.0d0/2240.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0,  -9.0d0/4480.0d0,  9.0d0/2240.0d0,&
 9.0d0/4480.0d0,  -9.0d0/8960.0d0,  0.0d0,          -9.0d0/8960.0d0, -9.0d0/8960.0d0,  0.0d0,           9.0d0/4480.0d0, &
 -9.0d0/8960.0d0,  0.0d0,           0.0d0,           0.0d0,          -9.0d0/4480.0d0,  0.0d0,           0.0d0          /)
p3_matrix(7,:) =(/ 1.0d0/8960.0d0, -1.0d0/2240.0d0,  1.0d0/4480.0d0,  1.0d0/8960.0d0,  -9.0d0/8960.0d0,  9.0d0/4480.0d0,&
 9.0d0/2240.0d0,  -9.0d0/4480.0d0, -9.0d0/8960.0d0,  0.0d0,           0.0d0,           0.0d0,           9.0d0/4480.0d0, &
 -9.0d0/8960.0d0, -9.0d0/8960.0d0,  0.0d0,           0.0d0,          -9.0d0/4480.0d0,  0.0d0,           0.0d0          /)
p3_matrix(8,:) =(/ 1.0d0/8960.0d0,  1.0d0/4480.0d0, -1.0d0/2240.0d0,  1.0d0/8960.0d0,   0.0d0,          -9.0d0/8960.0d0,&
-9.0d0/4480.0d0,   9.0d0/2240.0d0,  9.0d0/4480.0d0, -9.0d0/8960.0d0,  0.0d0,           0.0d0,          -9.0d0/8960.0d0, &
  0.0d0,           9.0d0/4480.0d0, -9.0d0/8960.0d0,  0.0d0,           0.0d0,          -9.0d0/4480.0d0,  0.0d0          /)
p3_matrix(9,:) =(/ 1.0d0/4480.0d0,  1.0d0/8960.0d0, -1.0d0/2240.0d0,  1.0d0/8960.0d0,  -9.0d0/8960.0d0,   0.0d0,         &
-9.0d0/8960.0d0,   9.0d0/4480.0d0,  9.0d0/2240.0d0, -9.0d0/4480.0d0, -9.0d0/8960.0d0,  0.0d0,           0.0d0,          &
  0.0d0,           9.0d0/4480.0d0, -9.0d0/8960.0d0,  0.0d0,           0.0d0,          -9.0d0/4480.0d0,  0.0d0          /)
p3_matrix(10,:)=(/-1.0d0/2240.0d0,  1.0d0/8960.0d0,  1.0d0/4480.0d0,  1.0d0/8960.0d0,   9.0d0/4480.0d0, -9.0d0/8960.0d0,&
 0.0d0,           -9.0d0/8960.0d0, -9.0d0/4480.0d0,  9.0d0/2240.0d0,  9.0d0/4480.0d0, -9.0d0/8960.0d0,  0.0d0,          &
  0.0d0,          -9.0d0/8960.0d0,  0.0d0,          -9.0d0/4480.0d0,  0.0d0,           0.0d0,           0.0d0          /)
p3_matrix(11,:)=(/-1.0d0/2240.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0,  1.0d0/4480.0d0,   9.0d0/4480.0d0, -9.0d0/8960.0d0,&
 0.0d0,            0.0d0,          -9.0d0/8960.0d0,  9.0d0/4480.0d0,  9.0d0/2240.0d0, -9.0d0/4480.0d0,  0.0d0,          &
 -9.0d0/8960.0d0,  0.0d0,          -9.0d0/8960.0d0, -9.0d0/4480.0d0,  0.0d0,           0.0d0,           0.0d0          /)
p3_matrix(12,:)=(/ 1.0d0/4480.0d0,  1.0d0/8960.0d0,  1.0d0/8960.0d0, -1.0d0/2240.0d0,  -9.0d0/8960.0d0,  0.0d0,         &
 0.0d0,            0.0d0,           0.0d0,          -9.0d0/8960.0d0, -9.0d0/4480.0d0,  9.0d0/2240.0d0, -9.0d0/8960.0d0, &
  9.0d0/4480.0d0, -9.0d0/8960.0d0,  9.0d0/4480.0d0,  0.0d0,           0.0d0,           0.0d0,          -9.0d0/4480.0d0 /)
p3_matrix(13,:)=(/ 1.0d0/8960.0d0, -1.0d0/2240.0d0,  1.0d0/8960.0d0,  1.0d0/4480.0d0,  -9.0d0/8960.0d0,  9.0d0/4480.0d0,&
 9.0d0/4480.0d0,  -9.0d0/8960.0d0,  0.0d0,           0.0d0,           0.0d0,          -9.0d0/8960.0d0,  9.0d0/2240.0d0, &
 -9.0d0/4480.0d0,  0.0d0,          -9.0d0/8960.0d0,  0.0d0,          -9.0d0/4480.0d0,  0.0d0,           0.0d0          /)
p3_matrix(14,:)=(/ 1.0d0/8960.0d0,  1.0d0/4480.0d0,  1.0d0/8960.0d0, -1.0d0/2240.0d0,   0.0d0,          -9.0d0/8960.0d0,&
-9.0d0/8960.0d0,   0.0d0,           0.0d0,           0.0d0,          -9.0d0/8960.0d0,  9.0d0/4480.0d0, -9.0d0/4480.0d0, &
  9.0d0/2240.0d0, -9.0d0/8960.0d0,  9.0d0/4480.0d0,  0.0d0,           0.0d0,           0.0d0,          -9.0d0/4480.0d0 /)
p3_matrix(15,:)=(/ 1.0d0/8960.0d0,  1.0d0/8960.0d0, -1.0d0/2240.0d0,  1.0d0/4480.0d0,   0.0d0,           0.0d0,         &
-9.0d0/8960.0d0,   9.0d0/4480.0d0,  9.0d0/4480.0d0, -9.0d0/8960.0d0,  0.0d0,          -9.0d0/8960.0d0,  0.0d0,          &
 -9.0d0/8960.0d0,  9.0d0/2240.0d0, -9.0d0/4480.0d0,  0.0d0,           0.0d0,          -9.0d0/4480.0d0,  0.0d0          /)
p3_matrix(16,:)=(/ 1.0d0/8960.0d0,  1.0d0/8960.0d0,  1.0d0/4480.0d0, -1.0d0/2240.0d0,   0.0d0,           0.0d0,         &
 0.0d0,           -9.0d0/8960.0d0, -9.0d0/8960.0d0,  0.0d0,          -9.0d0/8960.0d0,  9.0d0/4480.0d0, -9.0d0/8960.0d0, &
  9.0d0/4480.0d0, -9.0d0/4480.0d0,  9.0d0/2240.0d0,  0.0d0,           0.0d0,           0.0d0,          -9.0d0/4480.0d0 /)
p3_matrix(17,:)=(/ 3.0d0/2240.0d0,  3.0d0/4480.0d0,  3.0d0/4480.0d0,  3.0d0/4480.0d0,  -9.0d0/4480.0d0,  0.0d0,         &
 0.0d0,            0.0d0,           0.0d0,          -9.0d0/4480.0d0, -9.0d0/4480.0d0,  0.0d0,           0.0d0,          &
  0.0d0,           0.0d0,           0.0d0,           9.0d0/560.0d0,   9.0d0/1120.0d0,  9.0d0/1120.0d0,  9.0d0/1120.0d0 /)
p3_matrix(18,:)=(/ 3.0d0/4480.0d0,  3.0d0/2240.0d0,  3.0d0/4480.0d0,  3.0d0/4480.0d0,   0.0d0,          -9.0d0/4480.0d0,&
-9.0d0/4480.0d0,   0.0d0,           0.0d0,           0.0d0,           0.0d0,           0.0d0,          -9.0d0/4480.0d0, &
  0.0d0,           0.0d0,           0.0d0,           9.0d0/1120.0d0,  9.0d0/560.0d0,   9.0d0/1120.0d0,  9.0d0/1120.0d0 /)
p3_matrix(19,:)=(/ 3.0d0/4480.0d0,  3.0d0/4480.0d0,  3.0d0/2240.0d0,  3.0d0/4480.0d0,   0.0d0,           0.0d0,         &
 0.0d0,           -9.0d0/4480.0d0, -9.0d0/4480.0d0,  0.0d0,           0.0d0,           0.0d0,           0.0d0,          &
  0.0d0,          -9.0d0/4480.0d0,  0.0d0,           9.0d0/1120.0d0,  9.0d0/1120.0d0,  9.0d0/560.0d0,   9.0d0/1120.0d0 /)
p3_matrix(20,:)=(/ 3.0d0/4480.0d0,  3.0d0/4480.0d0,  3.0d0/4480.0d0,  3.0d0/2240.0d0,   0.0d0,           0.0d0,         &
 0.0d0,            0.0d0,           0.0d0,           0.0d0,           0.0d0,          -9.0d0/4480.0d0,  0.0d0,          &
 -9.0d0/4480.0d0,  0.0d0,          -9.0d0/4480.0d0,  9.0d0/1120.0d0,  9.0d0/1120.0d0,  9.0d0/1120.0d0,  9.0d0/560.0d0  /)












    end subroutine mass_mat

    subroutine gaussian_integral()

        gpoint(1,:)   = (/0.2500000000000000d0,  0.2500000000000000d0,  0.2500000000000000d0/)
        gpoint(2,:)   = (/0.7857142857142857d0,  0.0714285714285714d0,  0.0714285714285714d0/)
        gpoint(3,:)   = (/0.0714285714285714d0,  0.0714285714285714d0,  0.0714285714285714d0/)
        gpoint(4,:)   = (/0.0714285714285714d0,  0.0714285714285714d0,  0.7857142857142857d0/)
        gpoint(5,:)   = (/0.0714285714285714d0,  0.7857142857142857d0,  0.0714285714285714d0/)
        gpoint(6,:)   = (/0.1005964238332008d0,  0.3994035761667992d0,  0.3994035761667992d0/)
        gpoint(7,:)   = (/0.3994035761667992d0,  0.1005964238332008d0,  0.3994035761667992d0/)
        gpoint(8,:)   = (/0.3994035761667992d0,  0.3994035761667992d0,  0.1005964238332008d0/)
        gpoint(9,:)   = (/0.3994035761667992d0,  0.1005964238332008d0,  0.1005964238332008d0/)
        gpoint(10,:)  = (/0.1005964238332008d0,  0.3994035761667992d0,  0.1005964238332008d0/)
        gpoint(11,:)  = (/0.1005964238332008d0,  0.1005964238332008d0,  0.3994035761667992d0/)

        gweight(1)   = -0.0789333333333333d0
        gweight(2)   =  0.0457333333333333d0
        gweight(3)   =  0.0457333333333333d0
        gweight(4)   =  0.0457333333333333d0
        gweight(5)   =  0.0457333333333333d0
        gweight(6)   =  0.1493333333333333d0
        gweight(7)   =  0.1493333333333333d0
        gweight(8)   =  0.1493333333333333d0
        gweight(9)   =  0.1493333333333333d0
        gweight(10)  =  0.1493333333333333d0
        gweight(11)  =  0.1493333333333333d0

    end subroutine gaussian_integral












end module fem
