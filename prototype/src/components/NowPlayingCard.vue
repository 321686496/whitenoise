<template>
  <view class="npc app-card">
    <!-- 空态 -->
    <template v-if="!player.currentScene">
      <view class="npc-empty">
        <view class="npc-empty-ic"><Icon name="moon" :size="34" /></view>
        <text class="npc-empty-t">选一个场景，开始你的助眠之旅</text>
        <view class="npc-empty-btn" @click="goLibrary">去场景库</view>
      </view>
    </template>
    <!-- 播放态 -->
    <template v-else>
      <view class="npc-head">
        <text class="npc-name">{{ player.currentScene.name }}</text>
        <view class="npc-pill num">{{ player.tracks.length }}/{{ player.tracks.length }} 路</view>
      </view>
      <view class="npc-body">
        <view class="npc-wave" :class="{ paused: !player.isPlaying }" aria-hidden="true">
          <view v-for="i in 5" :key="i" class="npc-wave-bar" :style="{ animationDelay: (i * 0.12) + 's' }" />
        </view>
        <view class="npc-play" :aria-label="player.isPlaying ? '暂停' : '播放'" @click="onToggle">
          <Icon :name="player.isPlaying ? 'pause' : 'play'" :size="34" />
        </view>
      </view>
      <view class="npc-actions">
        <view class="npc-act" :class="{ on: player.timerMinutes > 0 }" aria-label="定时" @click="onTimer">
          <Icon name="timer" :size="20" />
          <text class="num">{{ player.timerMinutes > 0 ? player.timerMinutes + '分' : '定时' }}</text>
        </view>
        <view class="npc-act" aria-label="混音" @click="onMix">
          <Icon name="shuffle" :size="20" /><text>混音</text>
        </view>
        <view class="npc-act" :class="{ on: fav }" aria-label="收藏" @click="toggleFav">
          <Icon name="heart" :size="20" /><text>{{ fav ? '已收藏' : '收藏' }}</text>
        </view>
      </view>
    </template>
  </view>

  <!-- 混音底部 Sheet（首页主控卡自带面板宿主；与 PlayBar 面板互斥：首页不渲染 PlayBar）
       与卡片并列为根节点：.app-card 的 backdrop-filter 会捕获 fixed 后代，故不可嵌在卡内 -->
  <view class="npc-sheet-mask" v-if="player.showMixPanel" @click="closeMix">
    <view class="npc-sheet" @click.stop>
      <view class="npc-sheet-handle" aria-hidden="true" />
      <view class="npc-sheet-head">
        <text class="npc-sheet-title">当前混音</text>
        <view class="npc-sheet-count num" v-if="player.tracks.length > 0">{{ player.tracks.length }}/6 路</view>
        <view class="npc-sheet-close" aria-label="关闭" @click="closeMix">
          <Icon name="close" :size="18" color="var(--app-text-3)" />
        </view>
      </view>
      <scroll-view class="npc-sheet-list" scroll-y v-if="player.tracks.length > 0">
        <MixTrack
          v-for="track in player.tracks"
          :key="track.id"
          :name="track.name"
          :icon-name="track.iconName"
          :color="track.color"
          :volume="track.volume"
          :is-muted="track.muted"
          @volume-change="(v: number) => setTrackVolume(track.id, v)"
          @mute="toggleTrackMute(track.id)"
          @remove="removeTrack(track.id)"
        />
      </scroll-view>
      <view class="npc-sheet-empty" v-else>
        <text>暂无音轨，添加一个声音开始混音</text>
      </view>
      <view class="npc-sheet-add" @click="goLibrary">
        <Icon name="mixer" :size="18" /><text>添加声音</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Icon from '@/components/Icon.vue'
import MixTrack from '@/components/MixTrack.vue'
import { player, togglePlay, setTimer, setTrackVolume, toggleTrackMute, removeTrack } from '@/composables/usePlayer'

const fav = ref(false) // 收藏态接入 favorites 数据层（Task 11 前 UI 态即可，见计划备注）

const onToggle = () => {
  const ok = togglePlay()
  if (!ok) uni.showToast({ title: '请先选择场景', icon: 'none' })
}
const onTimer = () => { setTimer(30) }
const onMix = () => { player.showMixPanel = true }
const goLibrary = () => uni.navigateTo({ url: '/pages/library/library' })
const closeMix = () => { player.showMixPanel = false }
function toggleFav() { fav.value = !fav.value }
</script>

<style lang="scss" scoped>
.npc { padding: 40rpx; display: flex; flex-direction: column; gap: 32rpx; }
.npc-empty { display: flex; flex-direction: column; align-items: center; gap: 24rpx; padding: 24rpx 0; }
.npc-empty-ic {
  width: 128rpx; height: 128rpx; border-radius: 999rpx;
  background: var(--app-primary-soft); color: var(--app-primary);
  display: flex; align-items: center; justify-content: center;
}
.npc-empty-t { font-size: 28rpx; color: var(--app-text-2); }
.npc-empty-btn {
  padding: 18rpx 52rpx; border-radius: 999rpx;
  background: var(--app-primary); color: var(--app-on-primary); font-size: 27rpx; font-weight: 600;
  box-shadow: var(--app-shadow-2);
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); }
}
.npc-head { display: flex; align-items: center; justify-content: space-between; }
.npc-name { font-size: 38rpx; font-weight: 700; color: var(--app-text); letter-spacing: -0.3rpx; }
.npc-pill {
  padding: 8rpx 24rpx; border-radius: 999rpx; font-size: 22rpx; font-weight: 600;
  background: var(--app-primary-soft); color: var(--app-primary);
}
.npc-body { display: flex; align-items: center; gap: 32rpx; }
.npc-wave { flex: 1; display: flex; align-items: center; gap: 10rpx; height: 88rpx; }
.npc-wave-bar {
  width: 8rpx; border-radius: 999rpx; background: var(--app-primary);
  height: 30%; animation: npcBreath 1.6s ease-in-out infinite;
}
.npc-wave-bar:nth-child(2) { height: 55%; } .npc-wave-bar:nth-child(3) { height: 85%; }
.npc-wave-bar:nth-child(4) { height: 55%; } .npc-wave-bar:nth-child(5) { height: 30%; }
.npc-wave.paused .npc-wave-bar { animation-play-state: paused; opacity: .4; }
@keyframes npcBreath { 0%, 100% { transform: scaleY(.6); } 50% { transform: scaleY(1); } }
@media (prefers-reduced-motion: reduce) { .npc-wave-bar { animation: none; } }
.npc-play {
  width: 176rpx; height: 176rpx; border-radius: 999rpx; flex: none;
  background: linear-gradient(135deg, var(--app-primary), var(--app-primary-strong));
  color: var(--app-on-primary); box-shadow: var(--app-shadow-3);
  display: flex; align-items: center; justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); }
}
.npc-actions { display: flex; justify-content: space-around; }
.npc-act {
  display: flex; align-items: center; justify-content: center; gap: 10rpx; padding: 16rpx 24rpx;
  min-height: 88rpx; /* v2 触控达标（44px） */
  border-radius: 999rpx; font-size: 24rpx; color: var(--app-text-2);
  background: var(--app-surface-2); border: 1rpx solid var(--app-line);
  transition: transform var(--dur-fast) var(--ease-std), color var(--dur-fast), background var(--dur-fast);
  &:active { transform: scale(.96); }
  &.on { color: var(--app-primary); background: var(--app-primary-soft); border-color: transparent; }
}

/* ---------- 混音底部 Sheet（v2 §8/§9：顶部 xl=56rpx / shadow-4 / dur-slow + ease-std） ---------- */
.npc-sheet-mask {
  position: fixed; left: 0; top: 0; right: 0; bottom: 0;
  z-index: 300; background: var(--app-overlay);
  display: flex; align-items: flex-end;
  animation: npcMaskIn var(--dur-slow) var(--ease-std) both;
}
.npc-sheet {
  width: 100%; box-sizing: border-box; max-height: 82vh;
  display: flex; flex-direction: column;
  padding: 16rpx 32rpx calc(32rpx + env(safe-area-inset-bottom));
  background: var(--app-surface);
  border-top: 1rpx solid var(--app-line);
  border-radius: 56rpx 56rpx 0 0;
  box-shadow: var(--app-shadow-4), var(--app-inset);
  animation: npcSheetUp var(--dur-slow) var(--ease-std) both;
}
.npc-sheet-handle {
  width: 72rpx; height: 8rpx; border-radius: 999rpx;
  background: var(--app-sunken); margin: 0 auto 20rpx; flex: none;
}
.npc-sheet-head { display: flex; align-items: center; gap: 14rpx; flex: none; }
.npc-sheet-title { font-size: 30rpx; font-weight: 700; color: var(--app-text); letter-spacing: -0.3rpx; flex: 1; }
.npc-sheet-count {
  padding: 6rpx 20rpx; border-radius: 999rpx; font-size: 21rpx; font-weight: 600;
  background: var(--app-primary-soft); color: var(--app-primary);
}
.npc-sheet-close {
  width: 88rpx; height: 88rpx; flex: none; margin-right: -18rpx;
  border-radius: 999rpx; display: flex; align-items: center; justify-content: center;
  transition: transform var(--dur-fast) var(--ease-std), background var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.96); background: var(--app-press); }
}
.npc-sheet-list { flex: 1; min-height: 0; }
.npc-sheet-empty {
  padding: 48rpx 0; text-align: center; font-size: 25rpx; color: var(--app-text-2);
}
.npc-sheet-add {
  flex: none; margin-top: 20rpx; min-height: 88rpx; border-radius: 999rpx;
  display: flex; align-items: center; justify-content: center; gap: 12rpx;
  background: var(--app-surface-2); border: 1rpx solid var(--app-line);
  color: var(--app-primary); font-size: 27rpx; font-weight: 600;
  transition: transform var(--dur-fast) var(--ease-std);
  &:active { transform: scale(.98); }
}
@keyframes npcMaskIn { from { opacity: 0; } to { opacity: 1; } }
@keyframes npcSheetUp { from { transform: translateY(100%); } to { transform: translateY(0); } }
@media (prefers-reduced-motion: reduce) {
  .npc-sheet-mask, .npc-sheet { animation: none; }
}
</style>
