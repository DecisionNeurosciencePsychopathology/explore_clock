id_212794_run1_censor_union_1d=load('C:\Users\wilsonj3\Desktop\212794\censor_union.1D');
id_212794_run2_censor_union_1d=load('C:\Users\wilsonj3\Desktop\212794\run2\censor_union.1D');

id_220299_run1_censor_union_1d=load('C:\Users\wilsonj3\Desktop\220299\censor_union.1D');
id_220299_run2_censor_union_1d=load('C:\Users\wilsonj3\Desktop\220299\run2\censor_union.1D');

id_212794_run1_fb_1 = load('C:\Users\wilsonj3\Desktop\212794\1_forback.1D');
id_212794_run2_fb_1 = load('C:\Users\wilsonj3\Desktop\212794\run2\1_forback.1D');
id_212794_run1_fb_3 = load('C:\Users\wilsonj3\Desktop\212794\3_forback.1D');
id_212794_run2_fb_3 = load('C:\Users\wilsonj3\Desktop\212794\run2\3_forback.1D');

id_220299_run1_fb_1 = load('C:\Users\wilsonj3\Desktop\220299\1_forback.1D');
id_220299_run2_fb_1 = load('C:\Users\wilsonj3\Desktop\220299\run2\1_forback.1D');
id_220299_run1_fb_3 = load('C:\Users\wilsonj3\Desktop\220299\3_forback.1D');
id_220299_run2_fb_3 = load('C:\Users\wilsonj3\Desktop\220299\run2\3_forback.1D');

figure(1)
clf;
subplot(2,1,1)
plot(id_212794_run1_censor_union_1d)
axis([1 length(id_212794_run1_censor_union_1d) -0.5 1.5])
title('212794')
subplot(2,1,2)
plot(id_212794_run2_censor_union_1d)
axis([1 length(id_212794_run2_censor_union_1d) -0.5 1.5])
title('FD 0.9')

figure(2)
clf;
subplot(2,1,1)
plot(id_220299_run1_censor_union_1d)
axis([1 length(id_220299_run1_censor_union_1d) -0.5 1.5])
title('220299')
subplot(2,1,2)
plot(id_220299_run2_censor_union_1d)
axis([1 length(id_220299_run2_censor_union_1d) -0.5 1.5])
title('FD 0.9')

figure(3)
clf;
subplot(2,1,1)
plot(id_212794_run1_fb_1)
axis([1 length(id_212794_run1_fb_1) -0.5 1.5])
title('212794')
subplot(2,1,2)
plot(id_212794_run2_fb_1)
axis([1 length(id_212794_run2_fb_1) -0.5 1.5])
title('FB 1')

figure(4)
clf;
subplot(2,1,1)
plot(id_212794_run1_fb_3)
axis([1 length(id_212794_run1_fb_3) -0.5 1.5])
title('212794')
subplot(2,1,2)
plot(id_212794_run2_fb_3)
axis([1 length(id_212794_run2_fb_3) -0.5 1.5])
title('FB 3')


figure(5)
clf;
subplot(2,1,1)
plot(id_220299_run1_fb_1)
axis([1 length(id_220299_run1_fb_1) -0.5 1.5])
title('220299')
subplot(2,1,2)
plot(id_220299_run2_fb_1)
axis([1 length(id_220299_run2_fb_1) -0.5 1.5])
title('FB 1')

figure(6)
clf;
subplot(2,1,1)
plot(id_220299_run1_fb_3)
axis([1 length(id_220299_run1_fb_3) -0.5 1.5])
title('220299')
subplot(2,1,2)
plot(id_220299_run2_fb_3)
axis([1 length(id_220299_run2_fb_3) -0.5 1.5])
title('FB 3')