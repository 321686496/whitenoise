<template>
  <view class="onboarding-container">
    <view class="onboarding-bg"></view>

    <swiper
      class="onboarding-swiper"
      :current="currentPage"
      :duration="320"
      @change="onSwiperChange"
    >
      <swiper-item v-for="(item, index) in slides" :key="index">
        <view class="slide-content">
          <view class="slide-icon-wrap" :style="{ background: item.iconBg }">
            <Icon :name="item.icon" :size="80" color="#fff" />
          </view>
          <text class="slide-title">{{ item.title }}</text>
          <text class="slide-subtitle">{{ item.subtitle }}</text>
        </view>
      </swiper-item>
    </swiper>

    <view class="bottom-area">
      <view class="indicator-row">
        <view
          v-for="(_, index) in slides"
          :key="index"
          class="dot"
          :class="{ active: index === currentPage }"
        />
      </view>

      <view class="btn-row" v-if="currentPage < slides.length - 1">
        <view class="skip-btn" @click="goHome">
          <text class="skip-text">跳过</text>
        </view>
        <view class="next-btn" @click="goNext">
          <text class="next-text">下一步</text>
        </view>
      </view>

      <view class="btn-row-full" v-else>
        <view class="start-btn" @click="goHome">
          <text class="start-text">开始体验</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Icon from '@/components/Icon.vue'

const currentPage = ref(0)

const slides = [
  {
    icon: 'wave',
    title: '欢迎来到声栖',
    subtitle: '用声音构建你的专属宁静空间',
    iconBg: 'linear-gradient(135deg, #8296A8, #5F7A92)',
  },
  {
    icon: 'mixer',
    title: '自由混音',
    subtitle: '混合多种声音，创造属于你的白噪音配方',
    iconBg: 'linear-gradient(135deg, #7E9A74, #5F7A52)',
  },
  {
    icon: 'moon',
    title: '安心入眠',
    subtitle: '定时播放，伴你温柔入梦',
    iconBg: 'linear-gradient(135deg, #8E82A6, #6E6290)',
  },
]

const onSwiperChange = (e: any) => {
  currentPage.value = e.detail.current
}

const goNext = () => {
  if (currentPage.value < slides.length - 1) {
    currentPage.value++
  }
}

const goHome = () => {
  uni.switchTab({ url: '/pages/index/index' })
}
</script>

<style lang="scss" scoped>
.onboarding-container {
  position: relative;
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--app-bg, $app-bg);
  overflow: hidden;
}

.onboarding-bg {
  position: absolute;
  left: 0;
  top: 0;
  right: 0;
  height: 520rpx;
  background: linear-gradient(180deg, var(--app-bg-grad) 0%, var(--app-bg) 80%, rgba(255,255,255,0) 100%);
  pointer-events: none;
  z-index: 0;
}

.onboarding-swiper {
  flex: 1;
  width: 100%;
  z-index: 1;
}

.slide-content {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 0 64rpx;
}

.slide-icon-wrap {
  width: 200rpx;
  height: 200rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 56rpx;
  box-shadow: 0 16rpx 48rpx rgba(0, 0, 0, 0.12);
}

.slide-title {
  font-size: 48rpx;
  font-weight: 700;
  color: var(--app-text, $uni-text-color);
  letter-spacing: 2rpx;
  margin-bottom: 20rpx;
}

.slide-subtitle {
  font-size: 28rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  text-align: center;
  line-height: 1.6;
  padding: 0 20rpx;
}

.bottom-area {
  position: relative;
  z-index: 1;
  padding: 0 40rpx calc(env(safe-area-inset-bottom, 0rpx) + 48rpx);
}

.indicator-row {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 48rpx;
}

.dot {
  width: 14rpx;
  height: 14rpx;
  border-radius: 50%;
  background: var(--app-divider, $uni-border-color);
  transition: all 0.24s cubic-bezier(.4, 0, .2, 1);

  &.active {
    width: 40rpx;
    border-radius: 7rpx;
    background: var(--app-primary, $app-primary);
  }
}

.btn-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24rpx;
}

.skip-btn {
  padding: 22rpx 32rpx;
  transition: all 0.16s cubic-bezier(.4, 0, .2, 1);

  &:active {
    transform: scale(0.9);
  }
}

.skip-text {
  font-size: 28rpx;
  color: var(--app-text-2, $uni-text-color-grey);
  font-weight: 500;
}

.next-btn {
  flex: 1;
  background: var(--app-primary, $app-primary);
  border-radius: 26rpx;
  padding: 22rpx 0;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10rpx 26rpx color-mix(in srgb, var(--app-primary, $app-primary) 30%, transparent);
  transition: all 0.18s cubic-bezier(.4, 0, .2, 1);

  &:active {
    opacity: 0.82;
    transform: scale(0.97);
  }
}

.next-text {
  font-size: 29rpx;
  font-weight: 600;
  color: #fff;
  letter-spacing: 1rpx;
}

.btn-row-full {
  padding: 0;
}

.start-btn {
  width: 100%;
  background: var(--app-primary, $app-primary);
  border-radius: 26rpx;
  padding: 24rpx 0;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10rpx 26rpx color-mix(in srgb, var(--app-primary, $app-primary) 30%, transparent);
  transition: all 0.18s cubic-bezier(.4, 0, .2, 1);

  &:active {
    opacity: 0.82;
    transform: scale(0.97);
  }
}

.start-text {
  font-size: 30rpx;
  font-weight: 600;
  color: #fff;
  letter-spacing: 2rpx;
}
</style>
