<template>
  <view class="banner-wrap">
    <swiper
      class="banner-swiper"
      :circular="banners.length > 1"
      indicator-dots
      indicator-active-color="#FFFFFF"
      indicator-color="rgba(255,255,255,.45)"
      current="0"
      @change="onChange"
    >
      <swiper-item v-for="b in banners" :key="b.id">
        <view class="banner app-card-el" :style="{ background: b.gradient }" @click="onTap(b)">
          <view class="banner-icon">
            <Icon :name="b.icon" :size="34" color="rgba(255,255,255,.92)" />
          </view>
          <view class="banner-text">
            <text class="banner-title">{{ b.title }}</text>
            <text class="banner-sub" v-if="b.subtitle">{{ b.subtitle }}</text>
          </view>
          <view class="banner-cue" v-if="b.type === 'featured'">
            <Icon name="play" :size="18" color="rgba(255,255,255,.9)" />
          </view>
        </view>
      </swiper-item>
    </swiper>
    <view v-if="banners.length > 1 && false" class="banner-dots" />
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Icon from '@/components/Icon.vue'
import type { Banner, BannerAction } from '@/data/banners'

defineProps<{ banners: Banner[] }>()
const emit = defineEmits<{ (e: 'action', a: BannerAction): void }>()
const current = ref(0)
const onChange = (e: any) => { current.value = e.detail.current }
function onTap(b: Banner) { emit('action', b.action) }
</script>

<style lang="scss" scoped>
.banner-wrap { margin: 0 0 4rpx; }
.banner-swiper { height: 200rpx; }
.banner {
  height: 200rpx; box-sizing: border-box; border-radius: 32rpx;
  padding: 32rpx 44rpx; display: flex; align-items: center; gap: 30rpx;
  overflow: hidden; box-shadow: var(--app-shadow-2);
}
.banner-icon {
  width: 112rpx; height: 112rpx; border-radius: 999rpx; flex: none;
  background: rgba(255,255,255,.18);
  display: flex; align-items: center; justify-content: center;
}
.banner-text { flex: 1; display: flex; flex-direction: column; gap: 10rpx; min-width: 0; }
.banner-title { font-size: 34rpx; font-weight: 700; color: #fff; letter-spacing: -0.3rpx; }
.banner-sub { font-size: 25rpx; color: rgba(255,255,255,.82); }
.banner-cue {
  width: 72rpx; height: 72rpx; border-radius: 999rpx; flex: none;
  background: rgba(255,255,255,.22);
  display: flex; align-items: center; justify-content: center;
}
</style>