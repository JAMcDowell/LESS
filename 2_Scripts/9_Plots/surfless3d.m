function [Out] = surfless3d(Array3D,t)
figure;
Out = squeeze(Array3D(t,:,:));
surf(Out');
shading interp; view(2);
end

