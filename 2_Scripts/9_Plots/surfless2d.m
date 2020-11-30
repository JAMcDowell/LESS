function [] = surfless2d(Array2D)
    figure;
    surf(Array2D');
    shading interp; view(2);
end

